# Henryk's Gentoo kernels

Here are my configs for Gentoo kernels I use.

How to use:
- you need to have Gentoo kernel flavor installed with:
  ```shell
  emerge -an sys-kernel/gentoo-sources
  # selecting kernel sources
  eselect kernel list
  eselect kernel set 1
  # my kernels require initrd
  emerge -an sys-kernel/dracut
  ```
- configure kernel with our `*_defconfig`:
  ```shell
  cd /usr/src/linux
  cp /THIS_REPO/libvirt_defconfig /usr/src/linux/arch/x86/configs
  make libvirt_defconfig
  make menuconfig
  ```
- now build and install kernel with:
  ```shell
  make -j`nproc` && make modules_install && make install  
  # rebuild initramfs, use -f if ramdisk file already exists
  dracut --kver=`cat /usr/src/linux/include/config/kernel.release`
  ```
- you can save your custom config with:
  ```shell
  cd /usr/src/linux
  make savedefconfig
  cp defconfig /SOME_PATH/mynew_defconfig
  ```

