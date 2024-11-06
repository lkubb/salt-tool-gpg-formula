# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if gpg.get("pinentry_sane") %}

Sane pinentry is available:
  file.managed:
    - name: {{ gpg.lookup.pinentry_sane.path }}
    - source: {{ files_switch(["pinentry-sane"],
                              lookup="Sane pinentry is available"
                 )
              }}
    - context:
        pinentry_terminal: {{ gpg.lookup.pinentry_sane.terminal }}
    - template: jinja
    - user: root
    - group: {{ gpg.lookup.rootgroup }}
    - mode: '0755'
    - makedirs: true
{%- endif %}
