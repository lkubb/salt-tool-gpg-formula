{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- for user in gpg.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  {%- set dotconfig = user.dotconfig if dotconfig is mapping else {} %}

GnuPG configuration is synced for user '{{ user.name }}':
  file.recurse:
    - name: {{ user._gpg.confdir }}
    - source:
      - salt://dotconfig/{{ user.name }}/gnupg
      - salt://dotconfig/gnupg
    - context:
        user: {{ user | json }}
    - template: jinja
    - user: {{ user.name }}
    - group: {{ user.group }}
  {%- if dotconfig.get('file_mode') %}
    - file_mode: '{{ dotconfig.file_mode }}'
  {%- endif %}
    - dir_mode: '{{ dotconfig.get('dir_mode', '0700') }}'
    - clean: {{ dotconfig.get('clean', False) | to_bool }}
    - makedirs: True
{%- endfor %}
