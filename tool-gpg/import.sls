{%- from 'tool-gpg/map.jinja' import gpg -%}

include:
  - .package

{%- set trust_levels = {
  'expired' : '1',
  'unknown' : '2',
  'not_trusted': '3',
  'marginally': '4',
  'fully': '5',
  'ultimately': '6'
} %}

{%- for user in gpg.users | selectattr('gpg.import', 'defined') %}
  {%- for key, config in user.gpg.import.items() %}

    {%- set type = 'keyid' if config.get('is_keyid') else 'fingerprint' %}

Key file '{{ key }}' is present for user '{{ user.name }}':
  file.managed:
    - name: {{ user._gpg.confdir }}/imports/{{ key }}.gpg
    {%- if config.get('source') %}
    - source: {{ config.source }}
    - skip_verify: true
    {%- else %}
    - contents: |
        {{ config.text | indent(8) }}
    {%- endif %}
    - mode: '0600'
    - dir_mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - require:
      - GnuPG setup is completed

Key '{{ key }}' is present for user '{{ user.name }}':
  module.run:
    - gpg.import_key:
      - filename: {{ user._gpg.confdir }}/imports/{{ key }}.gpg
      - user: {{ user.name }}
      - gnupghome: {{ user._gpg.confdir }}
    - unless:
      - fun: gpg.get_key
        {{ type }}: {{ key }}
        user: {{ user.name }}
        gnupghome: {{ user._gpg.confdir }}
    - require:
      - Key file '{{ key }}' is present for user '{{ user.name }}'

Key '{{ key }}' is actually present (verify source poorly):
  module.run:
    - gpg.get_key:
      - {{ type }}: {{ key }}
      - user: {{ user.name }}
      - gnupghome: {{ user._gpg.confdir }}
    - require:
      - Key '{{ key }}' is present for user '{{ user.name }}'

    {%- if config.get('trust') in trust_levels %}
      {%- set trust_level = trust_levels[config.trust] %}
Key '{{ key }}' trust level is managed for user '{{ user.name }}':
  # gpg.trust_key does not support gnupghome @TODO
    # - gpg.trust_key:
    #   {{ type}}: {{ key }}
    #   trust_level: {{ config.trust }}
    #   user: {{ user.name }}
  cmd.run:
    - name: |
      {%- if 'keyid' == type %}
        echo "$(gpg --list-keys 0x1848792F9E2795E9 | head -n 2 | \
          tail -n 1 | awk '{$1=$1};1'):{{ trust_level }}" \
      {%- else %}
        echo '{{ key }}:{{ trust_level }}' | \
      {%- endif %}
          gpg --import-ownertrust --homedir '{{ user._gpg.confdir }}'
    - runas: {{ user.name }}
    - unless:
      - |
          sudo -u {{ user.name }} gpg --homedir '{{ user._gpg.confdir }}' --export-ownertrust | \
      {%- if 'keyid' == type %}
            grep "$(gpg --list-keys 0x1848792F9E2795E9 | head -n 2 | \
                    tail -n 1 | awk '{$1=$1};1'):{{ trust_level }}:"
      {%- else %}
            grep '{{ key }}:{{ trust_level }}:'
      {%- endif %}
    - require:
      - Key '{{ key }}' is actually present (verify source poorly)
    {%- endif %}
  {%- endfor %}
{%- endfor %}
