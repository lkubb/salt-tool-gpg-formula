{%- from 'tool-gpg/map.jinja' import gpg -%}

{%- if gpg.get('pinentry_sane') %}
Sane pinentry is available:
  file.managed:
    - name: {{ gpg._pinentry_sane }}
    - source: salt://tool-gpg/files/pinentry-sane
    - context:
        pinentry_terminal: {{ gpg.pinentry_sane_terminal | default("tty") }}
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - mode: '0755'
    - makedirs: true

  {%- for user in gpg.users | selectattr('_gpg.update_pinentry', 'defined') %}

GnuPG Agent config file exists for user {{ user.name }}:
  file.managed:
    - name: {{ user._gpg.confdir }}/gpg-agent.conf
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'

GnuPG Agent config file does not contain pinentry-program definition for user {{ user.name }}:
  file.replace:
    - name: {{ user._gpg.confdir }}/gpg-agent.conf
    - pattern: {{ "^pinentry-program.*" | regex_escape }}
    - repl: ''
    - onlyif:
      - grep -e "^pinentry-program.*" {{ user._gpg.confdir }}
    - unless:
      - grep -e "^pinentry-program {{ gpg._pinentry_sane }}$"
    - require:
      - GnuPG Agent config file exists for user {{ user.name }}

Pinentry program is set to pinentry-sane for user {{ user.name }}:
  file.append:
    - name: {{ user._gpg.confdir }}/gpg-agent.conf
    - text: pinentry-program {{ gpg._pinentry_sane }}
    - require:
      # because file.append does not allow owner/mode to be specified when file does not exist
      - GnuPG Agent config file exists for user {{ user.name }}
      # because duplicate definitions is bad form
      - GnuPG Agent config file does not contain pinentry-program definition for user {{ user.name }}
  {%- endfor %}

  {%- for user in gpg.users | selectattr('gpg.pinentry_sane', 'defined') | selectattr('gpg.pinentry_sane') |
                              selectattr('rchook', 'defined') | selectattr('rchook') %}

Sane pinentry defaults to terminal input during shell session for user {{ user.name }}:
  file.append:
    - name: {{ user.home }}/{{ user.rchook }}
    - text: |
        export PINENTRY_USER_DATA="USE_CURSES=1"
  {%- endfor %}
{%- endif %}
