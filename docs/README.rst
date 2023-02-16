.. _readme:

GnuPG Formula
=============

Manages GnuPG in the user environment, including imported public keys and trust settings.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_gpg`` will make sure ``gpg`` is configured as specified.

Salt minion settings
~~~~~~~~~~~~~~~~~~~~
For ``tool_gpg.pubkeys.import``, this formula requires the new syntax of `module.run`. To enable this prior to Salt v3005, include the following setting in your minion config:

.. code-block:: yaml

  use_superseded:
    - module.run

Shell environment
-----------------
Since GnuPG 2.1, `the agent runs with a fixed socket and is started on demand <https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart>`_. This obsoletes most of the examples of how to setup your shell environment for gpg (including the zsh prezto plugin). Currently, it's only necessary to ``export GPG_TTY=$(tty)`` in your shell runcom. Invoking ``gpg-connect-agent /bye`` starts the agent and is what would be needed if some application does not start it on demand. A prime example is OpenSSH.

SSH integration
~~~~~~~~~~~~~~~
Most applications start gpg-agent on demand, OpenSSH does not. Therefore, it needs to be started by the user (or his shellrc) before running ``ssh``:

.. code-block:: bash

  gpg-connect-agent /bye

This method comes with a problem though: When using a manually started ``gpg-agent`` in place of ``ssh-agent``, it does not know the current tty, only the one it was started with. If it is configured to use a terminal-based pinentry program, password prompts show up in the tty where it was started first. This is a problem especially in terminal multiplexers.

The fix for both problems is to teach OpenSSH to autostart ``gpg-agent`` in its config file [`1 <https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9>`_]:

  Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"

So just before every single connection, OpenSSH updates the ``gpg-agent`` default tty to the current one. If the agent was not running already, it is started as well. This workaround needs ``GPG_TTY=$(tty)`` to succeed.

.. note::

  You will also need to ``export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"`` somewhere in your shell runcom.

Note for zsh users
~~~~~~~~~~~~~~~~~~
``zsh`` specifically provides an environment variable, ``$TTY``. Using this with ``export GPG_TTY="$TTY"`` is `much faster <https://github.com/romkatv/powerlevel10k#how-do-i-export-gpg_tty-when-using-instant-prompt>`_ than the usual method.  If you use ``powerlevel10k`` with instant prompt enabled, it is `actually mandatory <https://unix.stackexchange.com/questions/608842/zshrc-export-gpg-tty-tty-says-not-a-tty>`_: ``tty`` requires stdin to be attached to a terminal, but ``powerlevel10k`` redirects stdin to ``/dev/null`` in that mode.

Sane pinentry
~~~~~~~~~~~~~
GnuPG will typically generally use a graphical pinentry if ``$DISPLAY`` is set, even if invoked from a terminal. This can cause problems (e.g. while connected through SSH) and breaks the flow. This formula contains a script called ``pinentry-sane`` that acts as a shim. If ``PINENTRY_USER_DATA="USE_CURSES=1"`` is set, it will invoke ``pinentry-tty`` or ``pinentry-curses``, depending on formula configuration, otherwise ``pinentry-mac`` or ``pinentry-x11``, depending on the system. This emulates the behavior of ``pinentry-mac`` for Linux and on MacOS provides the user with the choice of which terminal-based pinentry to use.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_gpg`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_gpg:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_gpg/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
    xdg: true

      # Sync this user's config from a dotfiles repo.
      # The available paths and their priority can be found in the
      # rendered `config/sync.sls` file (currently, @TODO docs).
      # Overview in descending priority:
      # salt://dotconfig/<minion_id>/<user>/gnupg
      # salt://dotconfig/<minion_id>/gnupg
      # salt://dotconfig/<os_family>/<user>/gnupg
      # salt://dotconfig/<os_family>/gnupg
      # salt://dotconfig/default/<user>/gnupg
      # salt://dotconfig/default/gnupg
    dotconfig:              # can be bool or mapping
      file_mode: '0600'     # default: keep destination or salt umask (new)
      dir_mode: '0700'      # default: 0700
      clean: false          # delete files in target. default: false

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_gpg:users`.
      # Set this to `false` to disable configuration for this user.
    gpg:
      agent:
          # gpg-agent.conf configuration options for this user
        config:
          default-cache-ttl: 10
            # set keys to empty values for the string without config value
          enable-ssh-support: ''
          max-cache-ttl: 120
          # make sure SSH_AUTH_SOCK is getting set properly in the shellrc
        hook: true
          # populate sshcontrol file (keys gpg-agent uses for ssh connections)
        sshcontrol: []
          # add hook to ssh to autoreset TTY to current one on ssh launch
        sshrc: .ssh/config
        # gpg.conf configuration options for this user
      config:
        charset: utf8
        keyid-format: 0xlong
        no-greeting: ''
        use-agent: ''
        with-fingerprint: ''
        # update gpg-agent.conf to use pinentry-sane
      pinentry_sane: true
        # automatically insert 'export PINENTRY_USER_DATA="USE_CURSES=1"'
        # into shell rc to make shim functional
      pinentry_update_rc: false
        # import pubkeys, either by file or text
      pubkeys:
          # specify fingerprint in raw hex, without 0x and spaces
          # can also be keyid, but that has compromises
        427F11FD0FAA4B080123F01CDDFA1A3E36879494:
          - source: salt://gpg/keys/qubes-master-signing.asc
            # optionally specify trust level, one of:
            # expired, unknown, not_trusted, marginally, fully, ultimately
          - trust: ultimately
            # or keyid, not recommended though
          - type: fingerprint
        5817A43B283DE5A9181A522E1848792F9E2795E9:
          - text: |-
              -----BEGIN PGP PUBLIC KEY BLOCK-----

              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
              dcBETivefvOIZRjSyZYUTg==
              =6A62
              -----END PGP PUBLIC KEY BLOCK-----

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_gpg:

      # Specify an explicit version (works on most Linux distributions) or
      # keep the packages updated to their latest version on subsequent runs
      # by leaving version empty or setting it to 'latest'
      # (again for Linux, brew does that anyways).
    version: latest
      # install shim that switches pinentry program depending on env
      # (terminal -> tty/curses, gui -> x11/pinentry-mac)
      # path and type (tty/curses) can be customized in lookup:pinentry_sane
    pinentry_sane: true

      # Default formula configuration for all users.
    defaults:
      agent: default value for all users

Config file serialization
~~~~~~~~~~~~~~~~~~~~~~~~~
This formula serializes configuration into a config file. A default one is provided with the formula, but can be overridden via the TOFS pattern. See :ref:`tofs_pattern` for details.

Dotfiles
~~~~~~~~
``tool_gpg.config.sync`` will recursively apply templates from

* ``salt://dotconfig/<minion_id>/<user>/gnupg``
* ``salt://dotconfig/<minion_id>/gnupg``
* ``salt://dotconfig/<os_family>/<user>/gnupg``
* ``salt://dotconfig/<os_family>/gnupg``
* ``salt://dotconfig/default/<user>/gnupg``
* ``salt://dotconfig/default/gnupg``

to the user's config dir for every user that has it enabled (see ``user.dotconfig``). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

The URL list above is in descending priority. This means user-specific configuration from wider scopes will be overridden by more system-specific general configuration.

Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
~~~~~~~

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

  $ gem install bundler
  $ bundle install
  $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``tool_gpg`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

References
----------

* https://web.archive.org/web/20211103123114/https://kevinlocke.name/bits/2019/07/31/prefer-terminal-for-gpg-pinentry/
* https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
* https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
* https://github.com/opopops/salt-gpg-formula
