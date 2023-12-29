Gentoo AMD X2 machine:

```shell
$ emerge -an app-misc/resolve-march-native app-portage/cpuid2cpuflags
$ resolve-march-native

-march=k8-sse3 -mtune=k8 -mcx16 -mno-tune=k8-sse3 -msahf --param=l1-cache-line-size=64 --param=l1-cache-size=64 --param=l2-cache-size=512

cpuid2cpuflags
CPU_FLAGS_X86: 3dnow 3dnowext mmx mmxext sse sse2 sse3
```

WARNING! Recent AMD CPUs (EPYC in Azure) dropped 3dnow support!
So to interesect these CPUs one has to omit `3dnow 3dnowext`  from
`CPU_FLAGS_X86` and also to append `-mno-3dnow` to `COMMON_FLAGS`

