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
- for automatic kernel install and ramdisk creation do this:
  ```shell
  emerge -an sys-boot/grub
  echo 'sys-kernel/installkernel dracut grub' >> /etc/portage/package.use/installkernel
  emerge -an sys-kernel/installkernel
  grub-install /dev/sdX
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
  ```
- only you you do not use above `installkernel` you need to manually create initramfs with:
  ```shell
  # rebuild initramfs, use -f if ramdisk file already exists
  dracut --kver=`cat /usr/src/linux/include/config/kernel.release`
  ```
- you can save your custom config with:
  ```shell
  cd /usr/src/linux
  make savedefconfig
  cp defconfig /SOME_PATH/mynew_defconfig
  ```

