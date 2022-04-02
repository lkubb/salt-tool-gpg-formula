Available States
================

The following states are found in this formula:


agent.sshrc
-----------
This teaches ssh to run the agent on demand and update the TTY to the current one.
Fixes authentication popups in random tty, especially inside tmux.
The usual fix of running the command on shell startup will result in
always pointing to the latest one. See:

    * https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
    * https://github.com/drduh/YubiKey-Guide/issues/301
    * https://unix.stackexchange.com/questions/554153/what-is-the-proper-configuration-for-gpg-ssh-and-gpg-agent-to-use-gpg-auth-sub


