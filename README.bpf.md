# Experiments with BPF


```
emerge -an dev-util/bcc
dispatch-conf
emerge -an dev-util/bcc

Required:
 * Messages for package dev-util/bcc-0.29.1-r1:

 *   CONFIG_BPF_SYSCALL:         is not set when it should be.
 *   CONFIG_NET_CLS_BPF:         is not set when it should be.
 *   CONFIG_NET_ACT_BPF:         is not set when it should be.
 *   CONFIG_BPF_EVENTS:  is not set when it should be.
 *   CONFIG_DEBUG_INFO:  is not set when it should be.
 *   CONFIG_FUNCTION_TRACER:     is not set when it should be.
 * Please check to make sure these options are set correctly.
 * Failure to do so may cause unexpected problems.
```

For: `dev-debug/bpftrace` also this options is needed
```
*   CONFIG_FTRACE_SYSCALLS:     is not set when it should be.
```

Here are kernel configs that support above BPF options:
- [kernels/linux-6.6.30-gentoo/bpf_defconfig](kernels/linux-6.6.30-gentoo/bpf_defconfig)
- [kernels/linux-6.6.30-gentoo/hardbpf_defconfig](kernels/linux-6.6.30-gentoo/hardbpf_defconfig)

NOTE: It should be possible to revalidate required kernel CONFIG options using
trick from https://forums.gentoo.org/viewtopic-t-1110538-start-0.html
```shell
ebuild $(equery w dev-util/bcc) setup clean
ebuild $(equery w dev-debug/bpftrace) setup clean
```
WARNING! `pkg_pretend()` in `*.ebuild` has nothing common with `emerge -p` (emerge pretend). It is
confusing coincidence...

However when you run:
```shell
# /usr/share/bcc/tools/tcpconnect -tdU

libbpf: failed to find valid kernel BTF
Error: The python packages dnslib and cachetools are required to use the -d/--dns option.
Install this package with:
	$ pip3 install dnslib cachetools
   or
	$ sudo apt-get install python3-dnslib python3-cachetools (on Ubuntu 18.04+)
```
Cachetools is there:
```shell
emerge -an dev-python/cachetools
```

Trying with venv:
```shell
python -m venv --system-site-packages ~/venvdnslib
bash
source ~/venvdnslib/bin/activate
pip install dnslib
exit # exitvevn
sudo bash
source /home/user/venvdnslib/bin/activate
/usr/share/bcc/tools/tcpconnect -tdU

(venvdnslib) gentoo-hard-23 /home/user # /usr/share/bcc/tools/tcpconnect -tdU
libbpf: failed to find valid kernel BTF
/virtual/main.c:190:26: error: no member named 'type' in 'struct iov_iter'
  190 |     if (msghdr->msg_iter.type != ITER_IOVEC)
      |         ~~~~~~~~~~~~~~~~ ^
/virtual/main.c:198:35: error: no member named 'iov' in 'struct iov_iter'
  198 |     if (buflen > msghdr->msg_iter.iov->iov_len)
      |                  ~~~~~~~~~~~~~~~~ ^
/virtual/main.c:208:38: error: no member named 'iov' in 'struct iov_iter'
  208 |     void *iovbase = msghdr->msg_iter.iov->iov_base;
      |                     ~~~~~~~~~~~~~~~~ ^
3 errors generated.
Traceback (most recent call last):
  File "/usr/share/bcc/tools/tcpconnect", line 530, in <module>
    b = BPF(text=bpf_text)
        ^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.11/site-packages/bcc/__init__.py", line 479, in __init__
    raise Exception("Failed to compile BPF module %s" % (src_file or "<text>"))
Exception: Failed to compile BPF module <text>
```
Above "virtual/main.c" corresponds to actual code in `/usr/share/bcc/tools/tcpconnect` but
line numbers are different.

I fixed above errors in this patch:
- [hard-profile/patches/bcc-tcpconnect-fix-incomplete.diff](hard-profile/patches/bcc-tcpconnect-fix-incomplete.diff)
But lot of other errors occurred then...


