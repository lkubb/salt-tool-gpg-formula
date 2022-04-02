# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}


{%- for user in gpg.users | selectattr('config', 'defined') | selectattr('config') %}

GnuPG config file is cleaned for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_gpg'].conffile }}
{%- endfor %}
