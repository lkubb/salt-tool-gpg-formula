# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_package_install }}

{%- set trust_levels = {
  'expired' : '1',
  'unknown' : '2',
  'not_trusted': '3',
  'marginally': '4',
  'fully': '5',
  'ultimately': '6'
} %}


{%- for user in gpg.users | selectattr('gpg.pubkeys', 'defined') %}
{%-   for key, config in user.gpg.pubkeys.items() %}

{%-     set type = 'keyid' if config.get('is_keyid') else 'fingerprint' %}

Key file '{{ key }}' is present for user '{{ user.name }}':
  file.managed:
    - name: {{ user._gpg.datadir | path_join('imports', key ~ '.gpg') }}
{%-     if config.get('source') %}
    - source: {{ config.source }}
    - skip_verify: true
{%-     else %}
    - contents: |
        {{ config.text | indent(8) }}
{%-     endif %}
    - mode: '0600'
    - dir_mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - unless:
      - fun: gpg.get_key
        {{ type }}: {{ key }}
        user: {{ user.name }}
        gnupghome: {{ user._gpg.datadir }}
    - require:
      - sls: {{ sls_package_install }}

Key '{{ key }}' is present for user '{{ user.name }}':
  module.run:
    - gpg.import_key:
      - filename: {{ user._gpg.datadir }}/imports/{{ key }}.gpg
      - user: {{ user.name }}
      - gnupghome: {{ user._gpg.datadir }}
    - unless:
      - fun: gpg.get_key
        {{ type }}: {{ key }}
        user: {{ user.name }}
        gnupghome: {{ user._gpg.datadir }}
    - require:
      - Key file '{{ key }}' is present for user '{{ user.name }}'

Key '{{ key }}' is actually present (verify source poorly) for user '{{ user.name }}':
  module.run:
    - gpg.get_key:
      - {{ type }}: {{ key }}
      - user: {{ user.name }}
      - gnupghome: {{ user._gpg.datadir }}
    - require:
      - Key '{{ key }}' is present for user '{{ user.name }}'
{%-   endfor %}
{%- endfor %}
