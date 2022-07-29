# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}


{%- for user in gpg.users | rejectattr('xdg', 'sameas', false) %}

{%-   set user_default_conf = user.home | path_join(gpg.lookup.paths.confdir) %}
{%-   set user_xdg_confdir = user.xdg.config | path_join(gpg.lookup.paths.xdg_dirname) %}
{%-   set user_xdg_conffile = user_xdg_confdir | path_join(gpg.lookup.paths.xdg_conffile) %}

GnuPG configuration is cluttering $HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user_default_conf }}
    - source: {{ user_xdg_confdir }}

GnuPG does not have its config folder in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.absent:
    - name: {{ user_xdg_confdir }}
    - require:
      - GnuPG configuration is cluttering $HOME for user '{{ user.name }}'

GnuPG does not use XDG dirs during this salt run:
  environ.setenv:
    - value:
        CONF: false
    - false_unsets: true

{%-   if user.get('persistenv') %}

GnuPG is ignorant about XDG location for user '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: |
        ^{{ 'export CONF="${XDG_CONFIG_HOME:-$HOME/.config}/' ~ gpg.lookup.paths.xdg_dirname | path_join(gpg.lookup.paths.xdg_conffile) ~ '"' | regex_escape }}$
    - repl: ''
    - ignore_if_missing: true
{%-   endif %}
{%- endfor %}
