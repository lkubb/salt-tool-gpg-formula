# vim: ft=sls

{#-
    Manages the GnuPG package configuration by

    * recursively syncing from a dotfiles repo
    * managing/serializing the config file afterwards

    Has a dependency on `tool_gpg.package`_.
#}

include:
  - .sync
  - .file
