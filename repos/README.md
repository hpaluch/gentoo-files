# Henryk repositories

Here are my experimental repositories.

# Henryk repo (henrykrepo)

My first general gentoo repository. I followed
instructions from:
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Portage/CustomTree#Creating_a_custom_ebuild_repository

Setup:
- copy all files from [henrykrepo/](henrykrepo/) to `/var/db/repos/`
- install `emerge -an app-eselect/eselect-repository`
- create or update file `/etc/portage/repos.conf/eselect-repo.conf`
  ```ini
  # created by eselect-repo
  
  [henrykrepo]
  location = /var/db/repos/henrykrepo
  ```

Disclaimer - I don't know how to register existing repository with `eselect
repository`!  I created mine with single command `eselect repository create
henrykrepo` and added `auto-sync = false` to
`/var/db/repos/henrykrepo/metadata/layout.conf`


# Resources

* https://wiki.gentoo.org/wiki/Handbook:AMD64/Portage/CustomTree
* https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds

