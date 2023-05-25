Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_gpg``
~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_gpg.package``
~~~~~~~~~~~~~~~~~~~~
Installs the GnuPG package only.


``tool_gpg.xdg``
~~~~~~~~~~~~~~~~
Ensures GnuPG adheres to the XDG spec
as best as possible for all managed users.
Has a dependency on `tool_gpg.package`_.


``tool_gpg.config``
~~~~~~~~~~~~~~~~~~~
Manages the GnuPG package configuration by

* recursively syncing from a dotfiles repo
* managing/serializing the config file afterwards

Has a dependency on `tool_gpg.package`_.


``tool_gpg.config.file``
~~~~~~~~~~~~~~~~~~~~~~~~
Manages the GnuPG package configuration.
Has a dependency on `tool_gpg.package`_.


``tool_gpg.config.sync``
~~~~~~~~~~~~~~~~~~~~~~~~
Syncs the GnuPG package configuration
with a dotfiles repo.
Has a dependency on `tool_gpg.package`_.


``tool_gpg.agent``
~~~~~~~~~~~~~~~~~~



``tool_gpg.agent.config``
~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.agent.hook``
~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.agent.sshcontrol``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.agent.sshrc``
~~~~~~~~~~~~~~~~~~~~~~~~
This teaches ssh to run the agent on demand and update the TTY to the current one.
Fixes authentication popups in random tty, especially inside tmux.
The usual fix of running the command on shell startup will result in
always pointing to the latest one. See:

    * https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
    * https://github.com/drduh/YubiKey-Guide/issues/301
    * https://unix.stackexchange.com/questions/554153/what-is-the-proper-configuration-for-gpg-ssh-and-gpg-agent-to-use-gpg-auth-sub


``tool_gpg.hook``
~~~~~~~~~~~~~~~~~



``tool_gpg.pinentry_sane``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pinentry_sane.config``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pinentry_sane.hook``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pinentry_sane.install``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pubkeys``
~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pubkeys.imported``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.pubkeys.trust_synced``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_gpg.clean``
~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_gpg`` meta-state
in reverse order.


``tool_gpg.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the GnuPG package.
Has a dependency on `tool_gpg.config.clean`_.


``tool_gpg.xdg.clean``
~~~~~~~~~~~~~~~~~~~~~~
Removes GnuPG XDG compatibility crutches for all managed users.


``tool_gpg.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the configuration of the GnuPG package.


``tool_gpg.hook.clean``
~~~~~~~~~~~~~~~~~~~~~~~



