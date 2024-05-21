This old kernel is supposed to be better compatible
with BPF programs from `dev-util/bcc`. Namely program
`/usr/share/bcc/tools/tcpconnect` when running with `-d`
parameter (DNS support).

As of May 2024 it can be installed by specifying kernel range:
```shell
$ emerge -an '<sys-kernel/gentoo-sources-5.11'

[ebuild  NS    ] sys-kernel/gentoo-sources-5.10.216 [6.6.30]
```

See [../../README.bpf.md](../../README.bpf.md) for details.

