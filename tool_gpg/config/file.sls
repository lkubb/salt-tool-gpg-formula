# vim: ft=sls

{#-
    Manages the GnuPG package configuration.
    Has a dependency on `tool_gpg.package`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}


{%- for user in gpg.users | selectattr("gpg.config", "defined") | selectattr("gpg.config") %}

GnuPG config file is managed for user '{{ user.name }}':
  file.managed:
    - name: {{ user["_gpg"].conffile }}
    - source: {{ files_switch(
                    [gpg.lookup.paths.conffile],
                    lookup="GnuPG config file is managed for user '{}'".format(user.name),
                    config=gpg,
                    custom_data={"users": [user.name]},
                 )
              }}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - dir_mode: '0700'
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        user: {{ user | json }}
{%- endfor %}
