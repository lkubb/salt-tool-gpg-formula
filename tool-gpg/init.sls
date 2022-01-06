{%- from 'tool-gpg/map.jinja' import gpg -%}

include:
  - .package
{%- if gpg.users | rejectattr('xdg', 'sameas', False) %}
  - .xdg
{%- endif %}
{%- if gpg.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
{%- if gpg.users | selectattr('gpg.config', 'defined') %}
  - .config
{%- endif %}
{%- if gpg.users | selectattr('gpg.agent', 'defined') %}
  - .agent
{%- endif %}
{%- if gpg.users | selectattr('rchook', 'defined') | selectattr('rchook') %}
  - .hook
{%- endif %}
{%- if gpg.users | selectattr('gpg.pinentry_sane', 'defined') | selectattr('gpg.pinentry_sane') %}
  - .pinentry
{%- endif %}
