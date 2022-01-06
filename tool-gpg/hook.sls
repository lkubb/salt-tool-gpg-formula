{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- for user in gpg.users | selectattr('rchook', 'defined') | selectattr('rchook') %}
GnuPG knows about current tty on shell startup for user {{ user.name }}:
  file.append:
    - name: {{ user.home}}/{{ user.rchook }}
    - text: export GPG_TTY="$(tty)"
{%- endfor %}
