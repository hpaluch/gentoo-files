Azure build server (Debian 12 Host, Gentoo is in chroot)

- CPU:
  - for: `Standard E4as v5 (4 vcpus, 32 GiB memory)`: `AMD EPYC 7763 64-Core Processor`
- GPU: N/A

```shell
$ emerge -an app-misc/resolve-march-native app-portage/cpuid2cpuflags
$ resolve-march-native

-march=znver3 -mno-mwaitx -mno-pku -mno-wbnoinvd -mshstk --param=l1-cache-line-size=64 --param=l1-cache-size=32 --param=l2-cache-size=512

$ cpuid2cpuflags

CPU_FLAGS_X86: aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sha sse sse2 sse3 sse4_1 sse4_2 sse4a ssse3
```

WARNING! Abov AMD CPU (EPYC in Azure) dropped 3dnow support!
So to interesect these CPUs one has to omit `3dnow 3dnowext`  from
`CPU_FLAGS_X86` and also to append `-mno-3dnow` to `COMMON_FLAGS`

