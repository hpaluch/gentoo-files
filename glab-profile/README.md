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
`yarn webpack`. When I tried 2nd time id did this:
* ensured (by adding entry to `/etc/hosts` that both commands work properly:
  ```shell
  ping `hostname`
  ping `hostname`
  ```
* increased limits for open files from 1024 to 65536, created file `/etc/security/limits.d/files.conf`
  on BUILD SERVER with contents:
  ```
  root            hard    nofile            65536
  root            soft    nofile            65536
  YOUR_USERNAME            hard    nofile            65536
  YOUR_USERNAME            soft    nofile            65536
  ```
* and relogin.

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
Suspecting that nodejs (installed `net-libs/nodejs-20.6.1`) is too fresh. On official page
- https://docs.gitlab.com/ee/install/installation.html
There is required 18.17.x


TODO: Configuration...
- https://wiki.gentoo.org/wiki/GitLab

