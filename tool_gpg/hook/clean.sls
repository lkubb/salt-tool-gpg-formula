# -*- coding: utf-8 -*-
# vim: ft=sls

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

GnuPG does not know about current tty on shell startup for user '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.rchook) }}
    - pattern: {{ 'export GPG_TTY="' ~ hook_str ~ '"' | regex_escape }}
    - repl: ''
    - ignore_if_missing: true
{%- endfor %}
