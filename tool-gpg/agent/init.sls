{%- from 'tool-gpg/map.jinja' import gpg -%}
{%- set users = gpg.users | selectattr('gpg.agent', 'defined') | list -%}

{%- if not users %}
include: []
{%- else %}
include:
  {%- for x in ['config', 'sshcontrol', 'sshrc'] %}
    {%- if users | selectattr('gpg.agent.' ~ x, 'defined') %}
  - .{{ x }}
    {%- endif %}
  {%- endfor %}
{%- endif %}
