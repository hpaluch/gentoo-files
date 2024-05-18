# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{2..13} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="Simple library to encode/decode DNS wire-format packets. Used by dev-util/bcc"
HOMEPAGE="
	https://github.com/paulc/dnslib
	https://pypi.org/project/dnslib/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"

# there is no standard test framework, but rather shell script
python_test() {
	VERSIONS=${EPYTHON}	./run_tests.sh || die
}

