# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}


{%- for user in gpg.users | selectattr('gpg.config', 'defined') | selectattr('gpg.config') %}

GnuPG config file is cleaned for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_gpg'].conffile }}

{%-   if user.xdg %}

GnuPG config dir is absent for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_gpg'].confdir }}
{%-   endif %}
{%- endfor %}
