# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_package_install }}


{%- set hook_str_map = {
  "zsh": "$TTY",
  "default": "$(tty)"
  } %}

{%- for user in gpg.users | selectattr('rchook', 'defined') | selectattr('rchook') %}
{%-   set hook_str = hook_str_map.get(user.shell, hook_str_map.default) %}
{#-   workaround for salt-ssh not working with match.filter_by #}

rchook file exists for gpg for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.rchook) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

GnuPG knows about current tty on shell startup for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.rchook) }}
    - text: export GPG_TTY="{{ hook_str }}"
    - require:
      - rchook file exists for gpg for user '{{ user.name }}'
      - sls: {{ sls_package_install }}
{%- endfor %}
