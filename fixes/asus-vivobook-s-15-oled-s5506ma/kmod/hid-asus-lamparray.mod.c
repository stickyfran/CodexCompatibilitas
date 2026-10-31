#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};


MODULE_INFO(depends, "led-class-multicolor,asus-wmi");

MODULE_ALIAS("hid:b0018g*v00000B05p000019B6");
MODULE_ALIAS("hid:b0018g*v00000B05p00005570");

MODULE_INFO(srcversion, "0C3B3FF055F9C86BA7B2B34");
