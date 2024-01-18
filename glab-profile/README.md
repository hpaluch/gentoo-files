# GitLab Gentoo profile

Attempt to install GitLab in Gentoo by following:
- https://wiki.gentoo.org/wiki/GitLab
- https://wiki.gentoo.org/wiki/Eselect/Repository

WARNING! It is experimental project! Use on your own risk!

Based on [../srv-profile/](../srv-profile/).

First we have to install "repository" module for `eselect`
```shell
emerge -an app-eselect/eselect-repository
mkdir -p /etc/portage/repos.conf
```
List of repos: https://repos.gentoo.org/

Following guide we have to enable and synchronize repo using:
```shell
eselect repository enable gitlab
emaint sync -r gitlab
```

You can see available GitLab versions under:
- `/var/db/repos/gitlab/www-apps/gitlab`

Now you need to copy these files to our Gentoo /:
```
etc/portage/package.accept_keywords/gitlab
etc/portage/package.use/gitlab
etc/portage/package.mask/gitlab
```

Finally you can start build:
```shell
emerge -an www-apps/gitlab
# in my case 50 new packages will be emerged...
```

TODO: Configuration...
- https://wiki.gentoo.org/wiki/GitLab

