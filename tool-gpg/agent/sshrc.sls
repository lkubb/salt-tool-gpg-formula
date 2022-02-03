{%- from 'tool-gpg/agent/init.sls' import users -%}

{%- for user in users | selectattr('gpg.agent.sshrc', 'defined') %}
# this teaches ssh to run the agent on demand and update the tty to the current one
# fix for authentication popups in random tty, especially inside tmux
# the usual fix of running the command on shell startup will always point
# to the latest one. see:
# https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
# https://github.com/drduh/YubiKey-Guide/issues/301
# https://unix.stackexchange.com/questions/554153/what-is-the-proper-configuration-for-gpg-ssh-and-gpg-agent-to-use-gpg-auth-sub
ssh config file exists for user '{{ user.name }}:
  file.managed:
    - name: {{ user.home }}/{{ user.gpg.agent.sshrc }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

SSH points gpg-agent to current TTY on connection for user '{{ user.name }}':
  file.append:
    - name: {{ user.home }}/{{ user.gpg.agent.sshrc }}
    - text: Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
    - require:
      - ssh config file exists for user '{{ user.name }}
{%- endfor %}
