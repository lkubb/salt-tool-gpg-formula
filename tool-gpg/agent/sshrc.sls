{%- from 'tool-gpg/agent/init.sls' import users -%}

{%- for user in users | selectattr('gpg.agent.sshrc', 'defined') %}
# this teaches ssh to run the agent on demand and update the tty to the current one
# fix for authentication popups in random tty, especially inside tmux
# the usual fix of running the command on shell startup will always point
# to the latest one. see:
# https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
# https://github.com/drduh/YubiKey-Guide/issues/301
# https://unix.stackexchange.com/questions/554153/what-is-the-proper-configuration-for-gpg-ssh-and-gpg-agent-to-use-gpg-auth-sub
SSH points gpg-agent to current TTY on connection (eg pinentry):
  file.append:
    - name: {{ user.home }}/{{ user.gpg.agent.sshrc }}
    - text: Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
{%- endfor %}
