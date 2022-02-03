{%- from 'tool-gpg/map.jinja' import gpg -%}

include:
  - .package

{%- for user in gpg.users | rejectattr('xdg', 'sameas', False) %}
Existing GnuPG configuration is migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.data }}/gnupg
    - source: {{ user.home }}/.gnupg
    - onlyif:
      - test -e {{ user.home }}/.gnupg
    - makedirs: true
    - prereq_in:
      - GnuPG setup is completed

GnuPG uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        GNUPGHOME: "{{ user.xdg.data }}/gnupg"
    - prereq_in:
      - GnuPG setup is completed

  {%- if user.get('persistenv') %}

persistenv file for gpg exists for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home }}/{{ user.persistenv }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

GnuPG knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home }}/{{ user.persistenv }}
    - text: export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
    - require:
      - persistenv file for gpg exists for user '{{ user.name }}'
    - prereq_in:
      - GnuPG setup is completed
  {%- endif %}

GnuPG XDG_CONFIG_HOME location exists for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.config }}/gnupg
    - mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - prereq_in:
      - GnuPG setup is completed

GnuPG config file is moved to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.config }}/gnupg/gpg.conf
    - source: {{ user.xdg.data }}/gnupg/gpg.conf
    - onlyif:
      - test -e {{ user.xdg.data }}/gnupg/gpg.conf
    - unless:
      - test -L {{ user.xdg.data }}/gnupg/gpg.conf
    - prereq_in:
      - GnuPG setup is completed

GnuPG config file location is symlinked to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.symlink:
    - name: {{ user.xdg.data }}/gnupg/gpg.conf
    - target: {{ user.xdg.config }}/gnupg/gpg.conf
    - user: {{ user.name }}
    - group: {{ user.group }}
    - prereq_in:
      - GnuPG setup is completed

GnuPG Agent config file is moved to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.config }}/gnupg/gpg-agent.conf
    - source: {{ user.xdg.data }}/gnupg/gpg-agent.conf
    - onlyif:
      - test -e {{ user.xdg.data }}/gnupg/gpg-agent.conf
    - unless:
      - test -L {{ user.xdg.data }}/gnupg/gpg-agent.conf
    - prereq_in:
      - GnuPG setup is completed

GnuPG Agent config file location is symlinked to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.symlink:
    - name: {{ user.xdg.data }}/gnupg/gpg-agent.conf
    - target: {{ user.xdg.config }}/gnupg/gpg-agent.conf
    - user: {{ user.name }}
    - group: {{ user.group }}
    - prereq_in:
      - GnuPG setup is completed

GnuPG Agent sshcontrol file is moved to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.config }}/gnupg/sshcontrol
    - source: {{ user.xdg.data }}/gnupg/sshcontrol
    - onlyif:
      - test -e {{ user.xdg.data }}/gnupg/sshcontrol
    - unless:
      - test -L {{ user.xdg.data }}/gnupg/sshcontrol
    - prereq_in:
      - GnuPG setup is completed

GnuPG Agent sshcontrol file location is symlinked to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.symlink:
    - name: {{ user.xdg.data }}/gnupg/sshcontrol
    - target: {{ user.xdg.config }}/gnupg/sshcontrol
    - user: {{ user.name }}
    - group: {{ user.group }}
    - prereq_in:
      - GnuPG setup is completed
{%- endfor %}
