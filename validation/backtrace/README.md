# Backtrace check

Summary: verify if glibc `backtrace(3)` crashes or not.

I found this issue when trying to `emerge -av emacs` on one Gentoo system. It crashed with:

```shell
./temacs --batch  -l loadup --temacs=pbootstrap \
        --bin-dest /usr/bin/ --eln-dest /usr/lib64/emacs/30.1/
make[2]: *** [Makefile:1016: bootstrap-emacs.pdmp] Aborted
```

Added `-g` to flags in `/etc/portage/make.conf`, rebuild and invoked GDB:

```shell
gdb --args ./temacs --batch  -l loadup --temacs=pbootstrap --bin-dest /usr/bin/ --eln-dest /usr/lib64/emacs/30.1/
(gdb) run

Starting program: /var/tmp/portage/app-editors/emacs-30.1-r2/work/emacs-30.1/src/temacs --batch -l loadup --temacs=pbootstrap --bin-dest /usr/bin/ --eln-d
est /usr/lib64/emacs/30.1/
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib64/libthread_db.so.1".

Program received signal SIGABRT, Aborted.
0x00007ffff7a64b0c in ?? () from /usr/lib64/libc.so.6
(gdb) bt
#0  0x00007ffff7a64b0c in ?? () from /usr/lib64/libc.so.6
#1  0x00007ffff7a0ebe6 in raise () from /usr/lib64/libc.so.6
#2  0x00007ffff79f68f7 in abort () from /usr/lib64/libc.so.6
#3  0x00007ffff75f079d in ?? () from /usr/lib/gcc/x86_64-pc-linux-gnu/14/libgcc_s.so.1
#4  0x00007ffff760f796 in _Unwind_Backtrace () from /usr/lib/gcc/x86_64-pc-linux-gnu/14/libgcc_s.so.1
#5  0x00007ffff7aee2c1 in backtrace () from /usr/lib64/libc.so.6
#6  0x0000555555637fbd in emacs_backtrace (backtrace_limit=backtrace_limit@entry=-1) at sysdep.c:2370
#7  0x0000555555568e21 in main (argc=<optimized out>, argv=<optimized out>) at emacs.c:1622
(gdb) quit
```

Just later found this page with same abort (but different conditions)
- https://issues.chromium.org/issues/41145149

What was my surprise when even this simple program happily crashes:

```shell
(gdb) run
Starting program: /home/ansible/projects/github.com/hpaluch/gentoo-files/validation/backtrace/backtrace
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib64/libthread_db.so.1".

Program received signal SIGABRT, Aborted.
0x00007ffff7e5db0c in ?? () from /usr/lib64/libc.so.6
(gdb) bt
#0  0x00007ffff7e5db0c in ?? () from /usr/lib64/libc.so.6
#1  0x00007ffff7e07be6 in raise () from /usr/lib64/libc.so.6
#2  0x00007ffff7def8f7 in abort () from /usr/lib64/libc.so.6
#3  0x00007ffff7d9e79d in ?? () from /usr/lib/gcc/x86_64-pc-linux-gnu/14/libgcc_s.so.1
#4  0x00007ffff7dbd796 in _Unwind_Backtrace () from /usr/lib/gcc/x86_64-pc-linux-gnu/14/libgcc_s.so.1
#5  0x00007ffff7ee72c1 in backtrace () from /usr/lib64/libc.so.6
#6  0x00005555555551bc in main (argc=1, argv=0x7fffffffdf58) at backtrace.c:12
```

Yup! Bu I don't now what is the cause (yet)....

I'm trying to build gcc and glibc with debug + source as described on:
- https://wiki.gentoo.org/wiki/Debugging

Reported here (no resolution yet):
- https://bugs.gentoo.org/955635

On clean system:
- worked until rebuild of glibc:

```shell
emerge -av1  sys-devel/binutils # ok
emerge -a1v sys-devel/gcc       # ok
emerge -a1v sys-libs/glibc      # crashes
```


