# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}


{%- for user in gpg.users | selectattr('gpg.agent', 'defined') | selectattr('gpg.agent.config', 'defined') %}

GnuPG Agent is configured as specified for user '{{ user.name }}':
  file.managed:
    - name: {{ user._gpg.confdir | path_join('gpg-agent.conf') }}
    - source: {{ files_switch(['gpg-agent.conf'],
                              lookup='GnuPG Agent is configured as specified for user \'{{ user.name }}\''
                 )
              }}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - dir_mode: '0700'
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        user: {{ user | json }}
{%- endfor %}
