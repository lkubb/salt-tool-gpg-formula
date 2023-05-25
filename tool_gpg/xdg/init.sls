# vim: ft=sls

{#-
    Ensures GnuPG adheres to the XDG spec
    as best as possible for all managed users.
    Has a dependency on `tool_gpg.package`_.
#}

include:
  - .migrated
