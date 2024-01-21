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


To diagnoste problems we will creaet local repo
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

Once it fails we can use shortcut (`install` also calls `src_install` where our build fails):
- Does not work that easy - you have to break `src_install` and backup `workhorse` and `scripts` before
  they are irrecoverably removed in later stage of install...
  ```shell
  # after artfificially inserted:
     die "Deliberate crash - backup `pwd`/workhorse and `pwd`/scripts"
  # to src_install() in ebuild 
  # backed up directories that will be removed
  tar cvzf /root/gitlab-build-backup.tar.gz \
     var/tmp/portage/www-apps/gitlab-16.3.7-r1/work/gitlab-16.3.7/workhorse \
     var/tmp/portage/www-apps/gitlab-16.3.7-r1/work/gitlab-16.3.7/scripts
  ```
- after failure you have to restore `scripts` and `workhorse` from backup and only then
  you can resume install stage using:

```shell
# restore files that are deleted on later install_src() stage:
tar xpvzf /root/gitlab-build-backup.tar.gz -C /
cd / 
ebuild /var/db/repos/local/www-apps/gitlab/gitlab-16.3.7-r1.ebuild install
# WARNING! ebuild actually uses /var/tmp/portage/www-apps/gitlab-16.3.7-r1/build-info/gitlab-16.3.7-r1.ebuild
# somehow - so if you update original ebuild you need to update also that copy...
```

By adding to `/var/tmp/portage/www-apps/gitlab-16.3.7-r1/work/gitlab-16.3.7/package.json`
```json
{
 scripts: {
   "webpack": "NODE_OPTIONS=\"--max-old-space-size=5120\" NODE_DEBUG=cluster,net,http,fs,tls,module,timers webpack --config config/webpack.config.js"
 }
}
```

Got more output but still mystery:
```
MODULE 10515: Module._load REQUEST @babel/template parent: /var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/g
itlab/node_modules/@babel/helpers/lib/helpers-generated.js                                                              
MODULE 10515: looking for "@babel/template" in ["/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/gitlab/node
_modules/@babel/helpers/lib/node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/gitlab/node_modul
es/@babel/helpers/node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/gitlab/node_modules/@babel/
node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/gitlab/node_modules","/var/tmp/portage/www-ap
ps/gitlab-16.3.7-r1/image/opt/gitlab/node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/node_modules","
/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/node_modules"
,"/var/tmp/portage/www-apps/node_modules","/var/tmp/portage/node_modules","/var/tmp/node_modules","/var/node_modules","/
node_modules","/var/tmp/portage/www-apps/gitlab-16.3.7-r1/homedir/.node_modules","/var/tmp/portage/www-apps/gitlab-16.3.
7-r1/homedir/.node_libraries","/usr/lib/node"]                                                                          
NET 10501: _read                                                                                                        
undefined:1                                                                                                             
{"type":"job","id":176,"error":null,"result":{"result":[{"buffer":true,"string":true},{"data":{"version":3,"names":["$",
"__","isExpanded","sectionArg","section","classList","contains","expandSection","$section","find","text","addClass","has
Class","one","removeClass","closeSection","toggleSection","initSettingsPanels","each","i","elm","on","window","location"
,"hash","$target","length","is"],"sources":["/var/tmp/portage/www-apps/gitlab-16.3.7-r1/image/opt/gitlab/gitlab/app/asse
ts/javascripts/settings_panels.js"],"sourcesContent":["import $ from 'jquery';\nimport { __ } from './locale';\n\n/**\n 
* Returns true if the given section is expanded or not\n *\n * For legacy consistency, it supports both jQuery and DOM e
lements\n *\n * @param {jQuery | Element} section\n */\nexport function isExpanded(sectionArg) {\n  const section = sect
ionArg instanceof $ ? sectionArg[0] : sectionArg;\n\n  return section.classList.contains('expanded');\n}\n\nexport funct
ion expandSection(sectionArg)
...
```
What is strange, that after "looking for" there should be "load", but there is instead
"undefined:1"

TODO: Configuration...
- https://wiki.gentoo.org/wiki/GitLab

