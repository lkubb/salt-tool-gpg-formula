# vim: ft=sls

{#-
  This teaches ssh to run the agent on demand and update the TTY to the current one.
  Fixes authentication popups in random tty, especially inside tmux.
  The usual fix of running the command on shell startup will result in
  always pointing to the latest one. See:

      * https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
      * https://github.com/drduh/YubiKey-Guide/issues/301
      * https://unix.stackexchange.com/questions/554153/what-is-the-proper-configuration-for-gpg-ssh-and-gpg-agent-to-use-gpg-auth-sub
-#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_package_install }}


{%- for user in gpg.users | selectattr("gpg.agent", "defined")
                          | selectattr("gpg.agent.sshrc", "defined")
                          | selectattr("gpg.agent.sshrc") %}

ssh config file exists for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.gpg.agent.sshrc) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

SSH points gpg-agent to current TTY on connection for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.gpg.agent.sshrc) }}
    - text: Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
    - require:
      - ssh config file exists for user '{{ user.name }}'
      - sls: {{ sls_package_install }}
{%- endfor %}
