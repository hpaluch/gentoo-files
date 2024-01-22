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

WARNING! On emerge of `www-apps/gitlab` it locked up right after
`yarn webpack`.

This time got build error:
```
undefined:1                                                                                                             
{"type":"job","id":778,"error":null,"result":{"result":[{"buffer":true,"string":true},{"data":{"version":3,"names":["dif
.... insane emount of json data ...
SyntaxError: Bad control character in string literal in JSON at position 24318                                 
    at JSON.parse (<anonymous>)                                                                                         
    at /var/tmp/portage/www-apps/gitlab-16.3.7/image/opt/gitlab/gitlab/node_modules/thread-loader/dist/WorkerPool.js:144
:30                                                                                                                     
    at Socket.onChunk (/var/tmp/portage/www-apps/gitlab-16.3.7/image/opt/gitlab/gitlab/node_modules/thread-loader/dist/r
eadBuffer.js:40:9)                                                                                                      
    at Socket.emit (node:events:514:28)                                                                                 
    at Readable.read (node:internal/streams/readable:558:10)                                                            
    at Socket.read (node:net:771:39)                                                                                    
    at flow (node:internal/streams/readable:1040:34)                                                                    
    at resume_ (node:internal/streams/readable:1021:3)
    at process.processTicksAndRejections (node:internal/process/task_queues:82:21)

Node.js v20.6.1
error Command failed with exit code 1.
info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.

Failing command:
 ${BUNDLE} exec rake yarn:install gitlab:assets:clean gitlab:assets:compile              
RAILS_ENV=${RAILS_ENV} NODE_ENV=${NODE_ENV}" || die "failed to update node dependencies and (re)compile assets";
```


Huh, found this: https://gitlab.awesome-it.de/overlays/gitlab/-/blob/master/www-apps/gitlab/gitlab-16.8.0.ebuild?ref_type=heads#L550
```shell
	einfo "Compiling assets ..."
	# On machines with few CPUs and/or without swap the webpack part of
	# gitlab:assets:compile may either stall or fail with the error
	# "SyntaxError: Bad control character in string literal in JSON".
	# Mitigation is to reduce the poolParallelJobs number from 200 to
	# a lower value (1 seems to work in any case). Supply the new value
	# through the WEBPACK_POLL_PARALLEL_JOBS environment variable.
	if [ "$WEBPACK_POLL_PARALLEL_JOBS" ]; then
		sed -i \
			-e "s|poolParallelJobs: .*,|poolParallelJobs: ${WEBPACK_POLL_PARALLEL_JOBS},|" \
			${ED}/${GITLAB_CONFIG}/webpack.config.js
	fi
```
Sounds familiar!

We can use to try:
```shell
mkdir -p ~/projects
cd ~/projects
git clone https://gitlab.awesome-it.de/overlays/gitlab.git overlay-gitlab
cd overlay-gitlab/
git log -S poolParallelJobs --source --all --oneline

522c5fe refs/heads/master (HEAD -> master, origin/master, origin/HEAD) New version 16.8.0
8f0709c refs/heads/master New versions 16.5.7, 16.6.5, 16.7.3
69dcfc8 refs/heads/master New versions 16.4.5, 16.5.6, 16.6.4, 16.7.2
3bbf5ac refs/heads/master New version 16.7.0
6fad6cc refs/heads/master New versions 16.[45].4, 16.6.2
e7a3485 refs/heads/master New versions 16.[45].3, 16.6.1 and cleanup
975830b refs/heads/master New version 16.6.0
954cce6 refs/heads/master New version 16.5.2
1473e57 refs/heads/master New versions 16.3.6, 16.4.2. 16.5.1
5a5479f refs/heads/master New version 16.5.0
```

To diagnose problems we will create local repo
- following: https://wiki.gentoo.org/wiki/Creating_an_ebuild_repository

```shell
# in Gentoo (or chroot of gentoo)
eselect repository create local
# above command will create /var/db/repo/local

# now copy ...

emerge -an dev-util/pkgdev
# created /var/db/repos/local/www-apps/gitlab/gitlab-16.3.7-r1.ebuild
# from  /var/db/repos/gitlab/www-apps/gitlab/gitlab-16.3.7.ebuild
cd /var/db/repos/local/www-apps/gitlab
pkgdev manifest
# Don't be scared that there is no Manifest file created (or is removed)
# It is because in development mode there is used so-called "thin" manifest.
pkgcheck scan
```
I updated max gitlab version in `/srv/gentoo/AZ-GLAB/etc/portage/package.mask/gitlab` to:
```
>www-apps/gitlab-16.4.0
```
Also commented out `MAKEOPTS="-jX"` in `/etc/portage/make.conf`

And then tried my `r1` build in debug mode:
```shell
emerge -and =www-apps/gitlab-16.3.7-r1
```

Please see [OldTroubles.md](OldTroubles.md) for reference what I tried (without success).

Here ebuild patch:
```diff
--- overlay-gitlab/www-apps/gitlab/gitlab-16.3.7.ebuild	2024-01-22 17:16:06.863505086 +0100
+++ gentoo-files/glab-profile/ebuilds/gitlab-16.3.7-r1.ebuild	2024-01-22 17:38:42.037320443 +0100
@@ -555,6 +555,10 @@
 	sed -i \
 		-e "s|${GITLAB_SHELL}|${ED}${GITLAB_SHELL}|g" \
 		config/gitlab.yml || die "failed to fake the gitlab-shell path"
+	einfo "Fixing webpack errors..."
+	sed -i \
+		-e "s|poolParallelJobs: .*,|poolParallelJobs: 1,|" \
+		${ED}/${GITLAB_CONFIG}/webpack.config.js
 	einfo "Updating node dependencies and (re)compiling assets ..."
 	/bin/sh -c "
 		${BUNDLE} exec rake yarn:install gitlab:assets:clean gitlab:assets:compile \
```

TODO: Configuration...
- https://wiki.gentoo.org/wiki/GitLab

