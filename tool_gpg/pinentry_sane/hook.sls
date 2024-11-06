# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_pinentry_install = slsdotpath ~ ".install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_pinentry_install }}


{%- if gpg.get("pinentry_sane") %}
{%-   for user in gpg.users | selectattr("gpg.pinentry_update_rc", "defined") | selectattr("gpg.pinentry_update_rc") |
                              selectattr("gpg.pinentry_sane", "defined") | selectattr("gpg.pinentry_sane") |
                              selectattr("rchook", "defined") | selectattr("rchook") %}

Sane pinentry defaults to terminal input during shell session for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.rchook) }}
    - text: |
        export PINENTRY_USER_DATA="USE_CURSES=1"
    - require:
      - sls: {{ sls_pinentry_install }}
{%-   endfor %}
{%- endif %}
