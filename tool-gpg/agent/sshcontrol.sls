{%- from 'tool-gpg/agent/init.sls' import users -%}

{%- for user in users | selectattr('gpg.agent.sshcontrol', 'defined') %}
GnuPG Agent knows about {{ user.name }}'s keys:
  file.managed:
    - name: {{ user._gpg.confdir }}/sshcontrol
    - source: salt://tool-gpg/agent/files/sshcontrol
    - template: jinja
    - context: {# though a simple list, put it into separate file to ease transition to TOFS pattern @TODO #}
        keygrips: {{ user.gpg.agent.sshcontrol | json }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true
{%- endfor %}
