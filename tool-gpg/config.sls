{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- for user in gpg.users | selectattr('gpg.config', 'defined') %}
GnuPG is configured as specified for user '{{ user.name }}':
  file.managed:
    - name: {{ user._gpg.confdir }}/gpg.conf
    - source: salt://tool-gpg/files/gpg.conf
    - context:
        config: {{ user.gpg.config }}
    - template: jinja
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
{%- endfor %}
