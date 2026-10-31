// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * ASUS Vivobook ITE5570 HID LampArray RGB Keyboard Driver
 *
 * Native kernel driver for ASUS Vivobook S 14 / S 15 / S 16 OLED
 * I2C-HID LampArray keyboards (ITE5570 0B05:19B6 and 0B05:5570).
 *
 * Features:
 *  - Native Linux Multicolor LED class (/sys/class/leds/asus::kbd_backlight_rgb)
 *  - Hardware Rainbow mode via ASUS WMI (0x0005002f OOBEKeybdLight)
 *  - Transparent tracking of OpenRGB / vrgb hidraw feature reports
 *  - 1:1 synchronization with ASUS WMI F4 keyboard backlight hotkeys (0, 85, 170, 255)
 *  - Fn-Lock (Fn+Esc) state tracking and restoration across reboot/suspend
 *  - Native kernel PM suspend/resume/reset_resume with active brightness memory
 *    and I2C bus wakeup delay (zero user-space processes and zero battery drain).
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/hid.h>
#include <linux/leds.h>
#include <linux/led-class-multicolor.h>
#include <linux/slab.h>
#include <linux/mutex.h>
#include <linux/delay.h>
#include <linux/workqueue.h>
#include <linux/input.h>
#include <linux/platform_data/x86/asus-wmi.h>

#define USB_VENDOR_ID_ASUSTEK		0x0b05
#define I2C_DEVICE_ID_ASUS_LAMPARRAY_1	0x19b6
#define I2C_DEVICE_ID_ASUS_LAMPARRAY_2	0x5570

#define ASUS_WMI_METHODID_DEVS		0x53564544 /* 'DEVS' */
#define ASUS_WMI_DEVID_OOBE_KBD_LIGHT	0x0005002f

/* Default profile ("Primero"): R=213 (0xD5), G=108 (0x6C), B=39 (0x27), Brightness=255 */
static uint default_red = 213;
module_param(default_red, uint, 0644);
MODULE_PARM_DESC(default_red, "Default Red intensity on boot (0-255)");

static uint default_green = 108;
module_param(default_green, uint, 0644);
MODULE_PARM_DESC(default_green, "Default Green intensity on boot (0-255)");

static uint default_blue = 39;
module_param(default_blue, uint, 0644);
MODULE_PARM_DESC(default_blue, "Default Blue intensity on boot (0-255)");

static uint default_brightness = 255;
module_param(default_brightness, uint, 0644);
MODULE_PARM_DESC(default_brightness, "Default global brightness on boot (0-255)");

static int default_fn_lock = -1;
module_param(default_fn_lock, int, 0644);
MODULE_PARM_DESC(default_fn_lock, "Default Fn-Lock state (-1: unchanged, 0: standard F1-F12, 1: media hotkeys)");

static bool turn_off_on_suspend = true;
module_param(turn_off_on_suspend, bool, 0644);
MODULE_PARM_DESC(turn_off_on_suspend, "Turn off keyboard LEDs during system suspend");

struct asus_lamparray_data {
	struct hid_device *hdev;
	const struct hid_ll_driver *orig_ll_driver;
	struct hid_ll_driver custom_ll_driver;
	struct led_classdev_mc mc_cdev;
	struct mc_subled subleds[3];
	struct mutex lock;

	struct asus_hid_listener wmi_listener;
	bool wmi_listener_registered;

	struct input_handler input_handler;
	struct input_handle *input_handle;
	bool input_handler_registered;

	struct work_struct wmi_work;
	u8 pending_wmi_brightness;

	u8 firmware_report_id;
	u8 color_report_id;
	bool has_wmi_rainbow;

	u8 r;
	u8 g;
	u8 b;
	u8 brightness;
	u8 last_active_brightness;
	int fn_lock_state;

	bool autonomous;
	bool rainbow_wmi;
	bool in_suspend;
	bool removing;
};

static int asus_lamparray_send_feature(struct asus_lamparray_data *data,
				       const u8 *payload, size_t len)
{
	u8 *dmabuf;
	int ret;

	if (!data || !data->hdev || !data->orig_ll_driver ||
	    !data->orig_ll_driver->raw_request)
		return -ENODEV;

	dmabuf = kmemdup(payload, len, GFP_KERNEL);
	if (!dmabuf)
		return -ENOMEM;

	ret = data->orig_ll_driver->raw_request(data->hdev, dmabuf[0], dmabuf,
						len, HID_FEATURE_REPORT,
						HID_REQ_SET_REPORT);
	kfree(dmabuf);
	return (ret < 0) ? ret : 0;
}

static int asus_lamparray_set_host_mode(struct asus_lamparray_data *data,
					bool host_mode)
{
	u8 buf[2] = {
		data->firmware_report_id,
		host_mode ? 0x00 : 0x01
	};

	return asus_lamparray_send_feature(data, buf, sizeof(buf));
}

static int asus_lamparray_send_color_hw(struct asus_lamparray_data *data,
					u8 r, u8 g, u8 b, u8 brightness)
{
	u8 buf[10] = {
		data->color_report_id,
		0x01, /* LampUpdateComplete flag */
		0x00, 0x00, /* LampIdStart = 0 */
		0x00, 0x00, /* LampIdEnd = 0 */
		r, g, b, brightness
	};

	return asus_lamparray_send_feature(data, buf, sizeof(buf));
}

static void asus_lamparray_set_wmi_rainbow(struct asus_lamparray_data *data,
					   bool enable)
{
	u32 retval = 0;

	if (!data->has_wmi_rainbow)
		return;

	/*
	 * In ASUS Vivobook S14/S15 EC firmware (0x0005002f OOBEKeybdLight):
	 *   0 = OOBE Demo Rainbow Active
	 *   1 = OOBE Complete (hand over control to HID LampArray)
	 */
	asus_wmi_evaluate_method(ASUS_WMI_METHODID_DEVS,
				 ASUS_WMI_DEVID_OOBE_KBD_LIGHT,
				 enable ? 0 : 1, &retval);
}

static int asus_lamparray_apply_state(struct asus_lamparray_data *data)
{
	int ret;

	if (data->rainbow_wmi) {
		asus_lamparray_set_wmi_rainbow(data, true);
		return asus_lamparray_set_host_mode(data, false);
	}

	asus_lamparray_set_wmi_rainbow(data, false);

	if (data->autonomous)
		return asus_lamparray_set_host_mode(data, false);

	ret = asus_lamparray_set_host_mode(data, true);
	if (ret)
		return ret;

	return asus_lamparray_send_color_hw(data, data->r, data->g, data->b,
					    data->brightness);
}

/*
 * Intercept raw_request from hidraw (e.g. OpenRGB / vrgb) so any color or
 * mode set by user-space tools is automatically remembered across suspend/resume.
 */
static int asus_lamparray_ll_raw_request(struct hid_device *hdev,
					 unsigned char reportnum, __u8 *buf,
					 size_t len, unsigned char rtype,
					 int reqtype)
{
	struct asus_lamparray_data *data = hid_get_drvdata(hdev);
	int ret;

	if (!data || !data->orig_ll_driver || !data->orig_ll_driver->raw_request)
		return -ENODEV;

	ret = data->orig_ll_driver->raw_request(hdev, reportnum, buf, len,
						rtype, reqtype);

	if (ret >= 0 && !data->in_suspend && !data->removing &&
	    rtype == HID_FEATURE_REPORT && reqtype == HID_REQ_SET_REPORT) {
		if (reportnum == data->color_report_id && len >= 10) {
			data->r = buf[6];
			data->g = buf[7];
			data->b = buf[8];
			data->brightness = buf[9];
			if (data->brightness > 0)
				data->last_active_brightness = data->brightness;
			data->autonomous = false;
			data->rainbow_wmi = false;

			data->subleds[0].intensity = data->r;
			data->subleds[1].intensity = data->g;
			data->subleds[2].intensity = data->b;
			data->mc_cdev.led_cdev.brightness = data->brightness;
		} else if (reportnum == data->firmware_report_id && len >= 2) {
			data->autonomous = (buf[1] != 0x00);
		}
	}

	return ret;
}

static int asus_lamparray_led_set(struct led_classdev *cdev,
				  enum led_brightness brightness)
{
	struct led_classdev_mc *mc_cdev = lcdev_to_mccdev(cdev);
	struct asus_lamparray_data *data =
		container_of(mc_cdev, struct asus_lamparray_data, mc_cdev);
	int ret = 0;

	mutex_lock(&data->lock);
	data->brightness = (u8)clamp_t(unsigned int, brightness, 0, 255);
	if (data->brightness > 0)
		data->last_active_brightness = data->brightness;

	data->r = (u8)clamp_t(unsigned int, data->subleds[0].intensity, 0, 255);
	data->g = (u8)clamp_t(unsigned int, data->subleds[1].intensity, 0, 255);
	data->b = (u8)clamp_t(unsigned int, data->subleds[2].intensity, 0, 255);
	data->autonomous = false;
	data->rainbow_wmi = false;

	if (!data->in_suspend)
		ret = asus_lamparray_apply_state(data);
	mutex_unlock(&data->lock);

	return ret;
}

static void asus_lamparray_wmi_work_func(struct work_struct *work)
{
	struct asus_lamparray_data *data =
		container_of(work, struct asus_lamparray_data, wmi_work);

	mutex_lock(&data->lock);
	data->brightness = data->pending_wmi_brightness;
	if (data->brightness > 0)
		data->last_active_brightness = data->brightness;
	data->mc_cdev.led_cdev.brightness = data->brightness;
	data->autonomous = false;
	data->rainbow_wmi = false;

	if (!data->in_suspend)
		asus_lamparray_apply_state(data);
	mutex_unlock(&data->lock);

	led_classdev_notify_brightness_hw_changed(&data->mc_cdev.led_cdev,
						  data->brightness);
}

/*
 * Listener called by asus-wmi whenever keyboard backlight level (0..3) changes
 * via F4 keyboard hotkey or desktop environment backlight slider.
 */
static void asus_lamparray_wmi_brightness_set(struct asus_hid_listener *listener,
					      int brightness)
{
	struct asus_lamparray_data *data =
		container_of(listener, struct asus_lamparray_data, wmi_listener);
	u8 new_brightness;

	switch (brightness) {
	case 0:
		new_brightness = 0;
		break;
	case 1:
		new_brightness = 85;
		break;
	case 2:
		new_brightness = 170;
		break;
	case 3:
	default:
		new_brightness = 255;
		break;
	}

	if (data->brightness == new_brightness)
		return;

	data->pending_wmi_brightness = new_brightness;
	schedule_work(&data->wmi_work);
}

static ssize_t rainbow_mode_show(struct device *dev,
				 struct device_attribute *attr, char *buf)
{
	struct led_classdev *cdev = dev_get_drvdata(dev);
	struct led_classdev_mc *mc_cdev = lcdev_to_mccdev(cdev);
	struct asus_lamparray_data *data =
		container_of(mc_cdev, struct asus_lamparray_data, mc_cdev);

	return sysfs_emit(buf, "%d\n", data->rainbow_wmi ? 1 : 0);
}

static ssize_t rainbow_mode_store(struct device *dev,
				  struct device_attribute *attr,
				  const char *buf, size_t count)
{
	struct led_classdev *cdev = dev_get_drvdata(dev);
	struct led_classdev_mc *mc_cdev = lcdev_to_mccdev(cdev);
	struct asus_lamparray_data *data =
		container_of(mc_cdev, struct asus_lamparray_data, mc_cdev);
	bool val;
	int ret;

	ret = kstrtobool(buf, &val);
	if (ret)
		return ret;

	mutex_lock(&data->lock);
	data->rainbow_wmi = val;
	data->autonomous = val;
	if (!data->in_suspend)
		ret = asus_lamparray_apply_state(data);
	mutex_unlock(&data->lock);

	return ret ? ret : count;
}
static DEVICE_ATTR_RW(rainbow_mode);

static ssize_t fn_lock_show(struct device *dev,
			    struct device_attribute *attr, char *buf)
{
	struct led_classdev *cdev = dev_get_drvdata(dev);
	struct led_classdev_mc *mc_cdev = lcdev_to_mccdev(cdev);
	struct asus_lamparray_data *data =
		container_of(mc_cdev, struct asus_lamparray_data, mc_cdev);

	return sysfs_emit(buf, "%d\n", data->fn_lock_state >= 0 ? data->fn_lock_state : 1);
}

static ssize_t fn_lock_store(struct device *dev,
			     struct device_attribute *attr,
			     const char *buf, size_t count)
{
	struct led_classdev *cdev = dev_get_drvdata(dev);
	struct led_classdev_mc *mc_cdev = lcdev_to_mccdev(cdev);
	struct asus_lamparray_data *data =
		container_of(mc_cdev, struct asus_lamparray_data, mc_cdev);
	bool val;
	u32 retval = 0;
	int ret;

	ret = kstrtobool(buf, &val);
	if (ret)
		return ret;

	mutex_lock(&data->lock);
	data->fn_lock_state = val ? 1 : 0;
	asus_wmi_set_devstate(ASUS_WMI_DEVID_FNLOCK, val ? 1 : 0, &retval);
	mutex_unlock(&data->lock);

	return count;
}
static DEVICE_ATTR_RW(fn_lock);

/* Input handler to detect physical Fn+Esc toggles (ASUS WMI event 0xeb) */
static void asus_lamparray_input_event(struct input_handle *handle,
				       unsigned int type, unsigned int code,
				       int value)
{
	struct asus_lamparray_data *data = handle->handler->private;

	if (!data)
		return;

	/* Detect Fn+Esc physical toggle (emits EV_MSC / MSC_SCAN 0xeb) */
	if (type == EV_MSC && code == MSC_SCAN && value == 0xeb) {
		mutex_lock(&data->lock);
		data->fn_lock_state = !data->fn_lock_state;
		mutex_unlock(&data->lock);

		if (data->mc_cdev.led_cdev.dev)
			sysfs_notify(&data->mc_cdev.led_cdev.dev->kobj, NULL, "fn_lock");

		hid_info(data->hdev, "Fn-Lock physical toggle (0xeb) -> state: %d\n",
			 data->fn_lock_state);
	}
}

static bool asus_lamparray_input_match(struct input_handler *handler,
				       struct input_dev *dev)
{
	return dev->name && strcmp(dev->name, "Asus WMI hotkeys") == 0;
}

static int asus_lamparray_input_connect(struct input_handler *handler,
					struct input_dev *dev,
					const struct input_device_id *id)
{
	struct asus_lamparray_data *data = handler->private;
	struct input_handle *handle;
	int error;

	if (!data)
		return -ENODEV;

	handle = kzalloc(sizeof(*handle), GFP_KERNEL);
	if (!handle)
		return -ENOMEM;

	handle->dev = dev;
	handle->handler = handler;
	handle->name = "asus_lamparray_fnlock";
	handle->private = data;

	error = input_register_handle(handle);
	if (error) {
		kfree(handle);
		return error;
	}

	error = input_open_device(handle);
	if (error) {
		input_unregister_handle(handle);
		kfree(handle);
		return error;
	}

	data->input_handle = handle;
	hid_info(data->hdev, "Connected to Asus WMI hotkeys for Fn-Lock tracking\n");
	return 0;
}

static void asus_lamparray_input_disconnect(struct input_handle *handle)
{
	struct asus_lamparray_data *data = handle->private;

	input_close_device(handle);
	input_unregister_handle(handle);
	if (data)
		data->input_handle = NULL;
	kfree(handle);
}

static const struct input_device_id asus_lamparray_input_ids[] = {
	{
		.flags = INPUT_DEVICE_ID_MATCH_EVBIT,
		.evbit = { BIT_MASK(EV_KEY) },
	},
	{ },
};

static int asus_lamparray_probe(struct hid_device *hdev,
				const struct hid_device_id *id)
{
	struct asus_lamparray_data *data;
	u32 retval = 0;
	int ret;

	/* Only bind to I2C-HID LampArray devices */
	if (hdev->bus != BUS_I2C)
		return -ENODEV;

	data = devm_kzalloc(&hdev->dev, sizeof(*data), GFP_KERNEL);
	if (!data)
		return -ENOMEM;

	mutex_init(&data->lock);
	data->hdev = hdev;
	INIT_WORK(&data->wmi_work, asus_lamparray_wmi_work_func);
	hid_set_drvdata(hdev, data);

	if (hdev->product == I2C_DEVICE_ID_ASUS_LAMPARRAY_1) {
		data->firmware_report_id = 0x0b;
		data->color_report_id = 0x05;
		data->has_wmi_rainbow = true;
	} else {
		data->firmware_report_id = 0x46;
		data->color_report_id = 0x45;
		data->has_wmi_rainbow = false;
	}

	data->r = (u8)clamp_t(uint, default_red, 0, 255);
	data->g = (u8)clamp_t(uint, default_green, 0, 255);
	data->b = (u8)clamp_t(uint, default_blue, 0, 255);
	data->brightness = (u8)clamp_t(uint, default_brightness, 0, 255);
	data->last_active_brightness = data->brightness ? data->brightness : 255;
	data->autonomous = false;
	data->rainbow_wmi = false;
	data->fn_lock_state = default_fn_lock;

	ret = hid_parse(hdev);
	if (ret) {
		hid_err(hdev, "Failed to parse HID report descriptor: %d\n", ret);
		return ret;
	}

	ret = hid_hw_start(hdev, HID_CONNECT_DEFAULT);
	if (ret) {
		hid_err(hdev, "Failed to start HID hardware: %d\n", ret);
		return ret;
	}

	/* Hook ll_driver->raw_request to track OpenRGB/vrgb hidraw changes */
	data->orig_ll_driver = hdev->ll_driver;
	data->custom_ll_driver = *hdev->ll_driver;
	data->custom_ll_driver.raw_request = asus_lamparray_ll_raw_request;
	hdev->ll_driver = &data->custom_ll_driver;

	/* Configure Multicolor LED class device */
	data->subleds[0].color_index = LED_COLOR_ID_RED;
	data->subleds[0].intensity = data->r;
	data->subleds[0].max_intensity = 255;
	data->subleds[0].channel = 0;

	data->subleds[1].color_index = LED_COLOR_ID_GREEN;
	data->subleds[1].intensity = data->g;
	data->subleds[1].max_intensity = 255;
	data->subleds[1].channel = 1;

	data->subleds[2].color_index = LED_COLOR_ID_BLUE;
	data->subleds[2].intensity = data->b;
	data->subleds[2].max_intensity = 255;
	data->subleds[2].channel = 2;

	data->mc_cdev.subled_info = data->subleds;
	data->mc_cdev.num_colors = 3;

	data->mc_cdev.led_cdev.name = "asus::kbd_backlight_rgb";
	data->mc_cdev.led_cdev.brightness = data->brightness;
	data->mc_cdev.led_cdev.max_brightness = 255;
	data->mc_cdev.led_cdev.brightness_set_blocking = asus_lamparray_led_set;
	data->mc_cdev.led_cdev.flags |= LED_BRIGHT_HW_CHANGED;

	ret = devm_led_classdev_multicolor_register(&hdev->dev, &data->mc_cdev);
	if (ret) {
		hid_warn(hdev, "Could not register multicolor LED class: %d\n", ret);
	} else if (data->mc_cdev.led_cdev.dev) {
		device_create_file(data->mc_cdev.led_cdev.dev, &dev_attr_rainbow_mode);
		device_create_file(data->mc_cdev.led_cdev.dev, &dev_attr_fn_lock);
	}

	/* Register ASUS WMI brightness listener (syncs with physical F4 hotkey) */
	data->wmi_listener.brightness_set = asus_lamparray_wmi_brightness_set;
	if (asus_hid_register_listener(&data->wmi_listener) == 0)
		data->wmi_listener_registered = true;

	/* Register input handler to track physical Fn+Esc toggles (WMI event 0xeb) */
	data->input_handler.name = "asus_lamparray_fnlock";
	data->input_handler.event = asus_lamparray_input_event;
	data->input_handler.connect = asus_lamparray_input_connect;
	data->input_handler.disconnect = asus_lamparray_input_disconnect;
	data->input_handler.match = asus_lamparray_input_match;
	data->input_handler.id_table = asus_lamparray_input_ids;
	data->input_handler.private = data;
	if (input_register_handler(&data->input_handler) == 0)
		data->input_handler_registered = true;

	/* Apply initial Fn-Lock state if configured */
	if (data->fn_lock_state >= 0) {
		asus_wmi_set_devstate(ASUS_WMI_DEVID_FNLOCK,
				      data->fn_lock_state ? 1 : 0, &retval);
	} else {
		data->fn_lock_state = 1;
		asus_wmi_set_devstate(ASUS_WMI_DEVID_FNLOCK, 1, &retval);
	}

	/* Apply initial RGB profile immediately at boot/probe */
	mutex_lock(&data->lock);
	asus_lamparray_apply_state(data);
	mutex_unlock(&data->lock);

	hid_info(hdev, "ASUS Vivobook LampArray RGB initialized (R=%u G=%u B=%u Br=%u FnLock=%d)\n",
		 data->r, data->g, data->b, data->brightness, data->fn_lock_state);

	return 0;
}

static void asus_lamparray_remove(struct hid_device *hdev)
{
	struct asus_lamparray_data *data = hid_get_drvdata(hdev);

	if (data) {
		data->removing = true;
		if (data->input_handler_registered) {
			input_unregister_handler(&data->input_handler);
			data->input_handler_registered = false;
		}
		if (data->wmi_listener_registered) {
			asus_hid_unregister_listener(&data->wmi_listener);
			data->wmi_listener_registered = false;
		}
		cancel_work_sync(&data->wmi_work);
		if (data->mc_cdev.led_cdev.dev) {
			device_remove_file(data->mc_cdev.led_cdev.dev, &dev_attr_fn_lock);
			device_remove_file(data->mc_cdev.led_cdev.dev, &dev_attr_rainbow_mode);
		}
		if (data->orig_ll_driver)
			hdev->ll_driver = data->orig_ll_driver;
	}
	hid_hw_stop(hdev);
}

#ifdef CONFIG_PM
static int asus_lamparray_suspend(struct hid_device *hdev, pm_message_t message)
{
	struct asus_lamparray_data *data = hid_get_drvdata(hdev);

	if (!data)
		return 0;

	mutex_lock(&data->lock);
	data->in_suspend = true;
	if (data->brightness > 0)
		data->last_active_brightness = data->brightness;

	if (turn_off_on_suspend && !data->autonomous) {
		asus_lamparray_send_color_hw(data, 0, 0, 0, 0);
	}
	mutex_unlock(&data->lock);

	return 0;
}

static int asus_lamparray_resume(struct hid_device *hdev)
{
	struct asus_lamparray_data *data = hid_get_drvdata(hdev);
	int ret = 0;
	u32 retval = 0;

	if (!data)
		return 0;

	/* Allow ITE5570 I2C microcontroller time to complete reset after sleep */
	msleep(50);

	mutex_lock(&data->lock);
	data->in_suspend = false;

	/* Restore active brightness if it was set to 0 before suspend */
	if (data->brightness == 0 && data->last_active_brightness > 0) {
		data->brightness = data->last_active_brightness;
		data->mc_cdev.led_cdev.brightness = data->brightness;
	}

	ret = asus_lamparray_apply_state(data);
	if (ret < 0) {
		msleep(50);
		ret = asus_lamparray_apply_state(data);
	}

	/* Re-apply Fn-Lock state after resume */
	if (data->fn_lock_state >= 0) {
		asus_wmi_set_devstate(ASUS_WMI_DEVID_FNLOCK,
				      data->fn_lock_state ? 1 : 0, &retval);
	}

	mutex_unlock(&data->lock);

	return ret;
}

static int asus_lamparray_reset_resume(struct hid_device *hdev)
{
	return asus_lamparray_resume(hdev);
}
#endif

static const struct hid_device_id asus_lamparray_devices[] = {
	{ HID_I2C_DEVICE(USB_VENDOR_ID_ASUSTEK, I2C_DEVICE_ID_ASUS_LAMPARRAY_1) },
	{ HID_I2C_DEVICE(USB_VENDOR_ID_ASUSTEK, I2C_DEVICE_ID_ASUS_LAMPARRAY_2) },
	{ }
};
MODULE_DEVICE_TABLE(hid, asus_lamparray_devices);

static struct hid_driver asus_lamparray_driver = {
	.name			= "asus_lamparray",
	.id_table		= asus_lamparray_devices,
	.probe			= asus_lamparray_probe,
	.remove			= asus_lamparray_remove,
#ifdef CONFIG_PM
	.suspend		= asus_lamparray_suspend,
	.resume			= asus_lamparray_resume,
	.reset_resume		= asus_lamparray_reset_resume,
#endif
};
module_hid_driver(asus_lamparray_driver);

MODULE_IMPORT_NS("ASUS_WMI");
MODULE_AUTHOR("Antigravity & Kes");
MODULE_DESCRIPTION("ASUS Vivobook ITE5570 HID LampArray Native RGB & Hotkey Driver");
MODULE_LICENSE("GPL");
