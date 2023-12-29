# Gentoo servers with AMD CPUs

Here are:
* [az-buildserver/](az-buildserver/) - build server in Azure (builds binary packages)
* [x2/](x2) - home computer (consumes binary packages)

We have to make intersection of both CPU features. Following:
- https://wiki.gentoo.org/wiki/GCC_optimization
- https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
- https://wiki.gentoo.org/wiki/Safe_CFLAGS

Last page provides way, how to get highest march and mtune switches:
```shell
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | grep mtune
```

