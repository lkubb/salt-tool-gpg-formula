{%- from 'tool-gpg/agent/init.sls' import users -%}

{%- for user in users | selectattr('gpg.agent.config', 'defined') %}
GnuPG Agent is configured as specified for user '{{ user.name }}':
  file.managed:
    - name: {{ user._gpg.confdir }}/gpg-agent.conf
    - source: salt://tool-gpg/files/gpg.conf
    - context:
        config: {{ user.gpg.agent.config }}
    - template: jinja
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
{%- endfor %}
