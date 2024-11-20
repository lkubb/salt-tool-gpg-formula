# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as gpg with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}


{%- for user in gpg.users | selectattr("gpg.agent", "defined") | selectattr("gpg.agent.sshcontrol", "defined") %}

GnuPG Agent knows about '{{ user.name }}'s keys:
  file.managed:
    - name: {{ user._gpg.confdir }}/sshcontrol
    - source: {{ files_switch(
                    ["sshcontrol"],
                    lookup="GnuPG Agent knows about '{}'s keys".format(user.name),
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
