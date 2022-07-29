# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}


GnuPG is installed:
  pkg.installed:
    - name: {{ gpg.lookup.pkg.name }}
    - version: {{ gpg.get('version') or 'latest' }}
    {#- do not specify alternative return value to be able to unset default version #}

{%- if gpg.lookup.pkg.misc %}

# eg on MacOS, install pinentry-mac by default
Miscellaneous packages related to GnuPG are installed:
  pkg.installed:
    - pkgs: {{ gpg.lookup.pkg.misc }}
    - require_in:
      - GnuPG setup is completed
{%- endif %}

GnuPG setup is completed:
  test.nop:
    - name: Hooray, GnuPG setup has finished.
    - require:
      - pkg: {{ gpg.lookup.pkg.name }}
