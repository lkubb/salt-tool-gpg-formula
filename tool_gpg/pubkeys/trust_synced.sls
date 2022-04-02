# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - .imported

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
{%-     if config.get('trust') in trust_levels %}
{%-       set trust_level = trust_levels[config.trust] %}

Key '{{ key }}' trust level is managed for user '{{ user.name }}':
  # gpg.trust_key does not support gnupghome @TODO
    # - gpg.trust_key:
    #   {{ type}}: {{ key }}
    #   trust_level: {{ config.trust }}
    #   user: {{ user.name }}
  cmd.run:
    - name: |
{%-       if 'keyid' == type %}
        echo "$(gpg --list-keys {{ key }} | head -n 2 | \
          tail -n 1 | awk '{$1=$1};1'):{{ trust_level }}" \

{%-       else %}
        echo '{{ key }}:{{ trust_level }}' | \

{%-       endif %}
          gpg --import-ownertrust --homedir '{{ user._gpg.confdir }}'
    - runas: {{ user.name }}
    - unless:
      - |
          sudo -u {{ user.name }} gpg --homedir '{{ user._gpg.confdir }}' --export-ownertrust | \
{%-       if 'keyid' == type %}
            grep "$(gpg --list-keys {{ key }} | head -n 2 | \
                    tail -n 1 | awk '{$1=$1};1'):{{ trust_level }}:"
      {%- else %}
            grep '{{ key }}:{{ trust_level }}:'
      {%- endif %}
    - require:
      - Key '{{ key }}' is actually present (verify source poorly) for user '{{ user.name }}'
    {%- endif %}
  {%- endfor %}
{%- endfor %}
