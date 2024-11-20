# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_package_install }}


{%- for user in gpg.users | selectattr("gpg.pubkeys", "defined") %}

Keys for user '{{ user.name }}' are managed:
  gpg.present:
    - names:
{%-   for key, config in user.gpg.pubkeys.items() %}
      - {{ key[-16:] }}:
        - skip_keyserver: {{ not not config.get("source") }}
        - source: {{ config.get("source") | json }}
        - text: {{ config.get("text") | json }}
        - keyserver: {{ config.get("keyserver") | json }}
        - trust: {{ config.get("trust") | json }}
{%-   endfor %}
    - user: {{ user.name }}
    - gnupghome: {{ user._gpg.datadir }}
{%- endfor %}
