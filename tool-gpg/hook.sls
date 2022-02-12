{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- for user in gpg.users | selectattr('rchook', 'defined') | selectattr('rchook') %}
rchook file exists for gpg for user {{ user.name }}:
  file.managed:
    - name: {{ user.home}}/{{ user.rchook }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

GnuPG knows about current tty on shell startup for user {{ user.name }}:
  file.append:
    - name: {{ user.home}}/{{ user.rchook }}
    - text: export GPG_TTY="$(tty)"
    - require:
      - rchook file exists for gpg for user {{ user.name }}
{%- endfor %}
