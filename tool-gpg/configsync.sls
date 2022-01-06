{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- for user in gpg.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
GnuPG configuration is synced for user '{{ user.name }}':
  file.recurse:
    - name: {{ user._gpg.confdir }}
    - source:
      - salt://dotconfig/{{ user.name }}/gnupg
      - salt://dotconfig/gnupg
    - context:
        user: {{ user }}
    - template: jinja
    - user: {{ user.name }}
    - group: {{ user.group }}
    - file_mode: keep
    - dir_mode: '0700'
    - makedirs: True
{%- endfor %}
