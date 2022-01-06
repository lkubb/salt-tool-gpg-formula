{%- from 'tool-gpg/map.jinja' import gpg -%}

GnuPG is installed:
  pkg.installed:
    - names: {{ gpg.package }}

GnuPG setup is completed:
  test.nop:
    - name: GnuPG setup has finished, hooray.
    - require:
{%- for pkg in gpg.package %}
      - pkg: {{ pkg }}
{%- endfor %}
