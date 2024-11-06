# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}

include:
  - {{ sls_package_install }}


{#- @TODO make sure that all the expected keys are initialized
    by default and skip the messy "defined" stuff #}

{%- for user in gpg.users | selectattr("rchook", "defined")
                          | selectattr("rchook")
                          | selectattr("gpg.agent", "defined")
                          | selectattr("gpg.agent.hook", "defined")
                          | selectattr("gpg.agent.hook") %}

rchook file exists for gpg-agent for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.rchook) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

ssh learns about gpg-agent socket on shell startup for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.rchook) }}
    - text: export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    - require:
      - rchook file exists for gpg-agent for user '{{ user.name }}'
      - sls: {{ sls_package_install }}
{%- endfor %}
