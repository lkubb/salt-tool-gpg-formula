# -*- coding: utf-8 -*-
# vim: ft=yaml
---
tool_global:
  users:
    user:
      configsync: true
      persistenv: .bash_profile
      rchook: .bashrc
      xdg: true
      gpg:
        agent:
          config:
            default-cache-ttl: 10
            enable-ssh-support: ''
            max-cache-ttl: 120
          hook: true
          sshcontrol: []
          sshrc: .ssh/config
        config:
          charset: utf8
          keyid-format: 0xlong
          no-greeting: ''
          use-agent: ''
          with-fingerprint: ''
        pinentry_sane: true
        pinentry_update_rc: false
        pubkeys:
          427F11FD0FAA4B080123F01CDDFA1A3E36879494:
            - source: salt://gpg/keys/qubes-master-signing.asc
            - trust: ultimately
            - type: fingerprint
          5817A43B283DE5A9181A522E1848792F9E2795E9:
            - text: |-
                -----BEGIN PGP PUBLIC KEY BLOCK-----

                mQINBFi9Xv4BEADTkOlBTDmO6DsFJi754ilTFqsluGWleeProuz8Q+bHFlx0Mqtk
                uOUcxIjEWwxhn1qN98dIPYds+mD9Bohamdh+bJYxB/YYj9B2xvURhCpxVlWzzkzt
                i1lPYhj/MR637N9JqIdILmJSBFDxmnuWfQxfsbIsi4lUx5oq6HzIAYXzUzA+0/0a
                c/j0zAm9oBq+pXPad/xkH8ebkNAL0+HbHArBNFzrhVKmi1VskpxurPIYZEcQ0dUu
                n447TM/37y+dzmNYxvSuK2zBPFa9upXsKZEoVaJqksXDdX2YuMsZFiesdieL85w7
                sD1iI6Eqmp5EIZXa8t0/MHTaDrm1tDKJdSu/5zrh0RFh+J73qxJH8lDJqcTVggCe
                Xoasoi1LNg0CIgzVM+zLEDbpNd6mILdXQNHzsU4CP2UFpMxOUUDMEPYSE3WBExWX
                0dBO8QgvTOzqvRWq7TL2jKaprsB/ZXiZief5hOK2QFL6HFEOuFuWLf3tb2+tpJoZ
                LXbXYW+6M+WNRHr9mDg3o6SuZmSwUCOa1FV/i51gqiUHmXEfIGH3iE5WWq2bvUG1
                dhjkzDGPL9fXbCWS6+QARakXRbxslsc4RgMrQR6nLEAuOL7GDaG3c7ldqgfotkal
                5KDB5/1AxYW1TC0JfoKWalYrfXlUJlbHcvDFqHdyljOnoeJ8WVqLNE9hUQARAQAB
                tB5RdWJlcyBPUyBSZWxlYXNlIDQgU2lnbmluZyBLZXmJAjcEEwEIACEFAli9Xv4C
                GwMFCwkIBwIGFQgJCgsCBBYCAwECHgECF4AACgkQGEh5L54nlem9QRAAkaDEfYey
                FoldssIDE/gliYYb7RSYBjs+QrYJQjBxFGXXPgHS5kGMZfMkqVVBc8EtHh41q7gU
                mUIHVbjnKIcYaKLaVl/qb9Jkx+6/NxEYWjNVEMMwPk820QgI1alWrweH7ZuxxGlz
                CzOQsyKZLH3TESEf46CUjv9FHW2nKPAp5qVMzLRlgtquQAdfh7SWau7Kd+WPQOiB
                9cj+j3/yswsrpLmvqJP8trS/aKAhsn2jGrxwSAbdGCzQorJjUy5HLZ6xVIk9yD0T
                +o9cbK4SQSuOHUiA9Z5gA7vuxwOuloDhIm74k2PBWMaUEvx19nIh4XmgGEKNzI6V
                SbR+s+d9ciQ/aC/bXdeeZOpCDaty54D8sKzMi2y15Urycxwpz508LwE6I3Zm0Won
                xMEf5gGR30szgQdh6sJKIqZ2nVDLBg4H1mc4CULhsgViN/vM3Rrj2t4kOwUM30AU
                M49o4JPzY4wvhsAmhIQGl38C8wDkSqPwntRsszpbLgzI3Lsxb00xiPcLR6Y/pviH
                AfHxh/1uYymjD1Fq9u9ylgR6+15qqEYY/uEHr2EQyVvXQ08R1iKkT+v8fufMFUWa
                rJxyB+5v/RPRKvRRi9Xb1HkoiFo3E/bEPYKlGA2colp5iqFYpTUBJYJXyMosgjI+
                mqH0I+V+LuMtlE521YHKg0tsB9GVlfWBS12JAjMEEAEKAB0WIQRCfxH9D6pLCAEj
                8Bzd+ho+NoeUlAUCYaQmlwAKCRDd+ho+NoeUlB40D/0YwLGqX5O6tl/q0Vehud2N
                mm5OIpxSZKrpm8vNtf2/rzumBldFSczCtVAkHo4N23hC+IGKHSG7lFZlFue/cng0
                ngopJsfhbj8eAbtdo9lqiqQaiFtUrB8hTd1HgvHjCptBKrSKn4FlJJ91ypLkoyiX
                27TcfToyEq6qFAWKXXQosYtCzh492WlD7GXXz32/1LnZKMS3TR4x+QfVRc9kn8X5
                HaempDgWw79d7ZAcSDuO4Kb2j/se4aLESTefKtJJ9LuPqhHZ+qGekUCyweiZ+mkR
                ok6XcaOHJEJgsvG1DIGwrGXyKkvqi12W8Q95XAF7y7C98vq4cVyhiLrBCbdgMY4X
                l9vHXIVEL3C032qu4AaeJ2tHZJvl1+nYqam8urQ/APk6pPVs75+IkH7zDfEHh+SF
                m6xAg/0fMKhYDlXB7l3UbiioV8vhBlHEf4XFR/VnnqM1B1TwdjywAbenc9Ev45L0
                5oqfrerACvYMxUxQVR0WQyrsLjJzinKZjjZW5KYiRn9lO+27rp1kMQHQFhNX1pnj
                oVnJIi0AtwAXumKI78SQpVRMjj6+fqusI/1Zx63XcI9Y8BBZvssYscgt2c9oMtBT
                B/Ng9EaplpSSVCsdcN85VAR7CZT5YPsvsMzSmmUUIRoEb/dHMuMmh0YbBJbBUikP
                dcBETivefvOIZRjSyZYUTg==
                =6A62
                -----END PGP PUBLIC KEY BLOCK-----
tool_gpg:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value

    pkg:
      name: gnupg
    paths:
      confdir: '.gnupg'
      conffile: 'gpg.conf'
      xdg_dirname: 'gnupg'
      xdg_conffile: 'gpg.conf'
    pinentry_sane:
      path: /usr/local/bin/pinentry-sane
      terminal: tty
  pinentry_sane: true

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://tool_gpg/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   tool-gpg-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      GnuPG config file is managed for user 'user':
        - 'gpg.conf'
        - 'gpg.conf.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
