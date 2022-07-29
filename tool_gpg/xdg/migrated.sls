# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ tplroot }}.package


{%- for user in gpg.users | rejectattr('xdg', 'sameas', false) %}

{%-   set user_default_conf = user.home | path_join(gpg.lookup.paths.confdir) %}
{%-   set user_xdg_confdir = user.xdg.config | path_join(gpg.lookup.paths.xdg_dirname) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(gpg.lookup.paths.xdg_dirname) %}
{%-   set conffiles = ['gpg.conf', 'gpg-agent.conf', 'sshcontrol'] %}

# workaround for file.rename not supporting user/group/mode for makedirs
GnuPG has its data dir in XDG_DATA_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.data }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true
    - onlyif:
      - test -e '{{ user_default_conf }}'

Existing GnuPG configuration is migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user_xdg_datadir }}
    - source: {{ user_default_conf }}
    - require:
      - GnuPG has its data dir in XDG_DATA_HOME for user '{{ user.name }}'
    - require_in:
      - GnuPG setup is completed

GnuPG has its config files in XDG_DATA_HOME for user '{{ user.name }}':
  file.managed:
    - names:
{%-   for file in conffiles %}
        - {{ user_xdg_datadir | path_join(file) }}:
          - unless:
            - test -f '{{ user_xdg_confdir | path_join(file) }}'
{%-   endfor %}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - makedirs: true
    - mode: '0600'
    - dir_mode: '0700'
    - require:
      - Existing GnuPG configuration is migrated for user '{{ user.name }}'
    - require_in:
      - GnuPG setup is completed

# workaround for file.rename not supporting user/group/mode for makedirs
GnuPG has its config dir in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user_xdg_confdir }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true
    - require_in:
      - GnuPG setup is completed

GnuPG config files are moved to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.rename:
    - names:
{%-   for file in conffiles %}
        - {{ user_xdg_confdir | path_join(file) }}:
          - source: {{ user_xdg_datadir | path_join(file) }}
          - unless:
            - test -L '{{ user_xdg_datadir | path_join(file) }}'
{%-   endfor %}
    - require:
      - GnuPG has its config files in XDG_DATA_HOME for user '{{ user.name }}'
      - GnuPG has its config dir in XDG_CONFIG_HOME for user '{{ user.name }}'
    - require_in:
      - GnuPG setup is completed

GnuPG config files' locations are symlinked to XDG_CONFIG_HOME for user '{{ user.name }}':
  file.symlink:
    - names:
{%-   for file in conffiles %}
        - {{ user_xdg_datadir | path_join(file) }}:
          - target: {{ user_xdg_confdir | path_join(file) }}
{%-   endfor %}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      - GnuPG config files are moved to XDG_CONFIG_HOME for user '{{ user.name }}'
    - require_in:
      - GnuPG setup is completed

# @FIXME
# This actually does not make sense and might be harmful:
# Each file is executed for all users, thus this breaks
# when more than one is defined!
GnuPG uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        GNUPGHOME: {{ user_xdg_confdir }}
    - require_in:
      - GnuPG setup is completed

{%-   if user.get('persistenv') %}

persistenv file for GnuPG exists for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.persistenv) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

GnuPG knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/{{ gpg.lookup.paths.xdg_dirname }}"
    - require:
      - persistenv file for GnuPG exists for user '{{ user.name }}'
    - require_in:
      - GnuPG setup is completed
{%-   endif %}
{%- endfor %}
