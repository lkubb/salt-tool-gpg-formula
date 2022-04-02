# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_pinentry_install = slsdotpath ~ '.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_pinentry_install }}


{%- if gpg.get('pinentry_sane') %}
{%-   for user in gpg.users | selectattr('_gpg.update_pinentry', 'defined') %}

gpg-agent.conf exists for user '{{ user.name }}' for pinentry:
  file.managed:
    - name: {{ user._gpg.confdir | path_join('gpg-agent.conf') }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - makedirs: true
    - dir_mode: '0700'

gpg-agent.conf does not contain pinentry-program definition for user '{{ user.name }}':
  file.replace:
    - name: {{ user._gpg.confdir | path_join('gpg-agent.conf') }}
    - pattern: ^pinentry-program.*\n
    - repl: ''
    - onlyif:
      - grep -e "^pinentry-program.*" '{{ user._gpg.confdir | path_join('gpg-agent.conf') }}'
    - unless:
      - grep -e "^pinentry-program\ {{ gpg.lookup.pinentry_sane.path | regex_escape }}$" '{{ user._gpg.confdir | path_join('gpg-agent.conf') }}'
    - require:
      - gpg-agent.conf exists for user '{{ user.name }}' for pinentry
      - sls: {{ sls_pinentry_install }}

Pinentry program is set to pinentry-sane for user '{{ user.name }}':
  file.append:
    - name: {{ user._gpg.confdir | path_join('gpg-agent.conf') }}
    - text: pinentry-program {{ gpg.lookup.pinentry_sane.path }}
    - require:
      # because file.append does not allow owner/mode to be specified
      - gpg-agent.conf exists for user '{{ user.name }}' for pinentry
      # because duplicate definitions is bad form
      - gpg-agent.conf does not contain pinentry-program definition for user '{{ user.name }}'
      - sls: {{ sls_pinentry_install }}
{%-   endfor %}
{%- endif %}
