# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{%- if hass.db.type != "sqlite" %}
{%-   from tplroot ~ "/post-map.jinja" import db_url with context %}
{%- endif %}

include:
  - {{ sls_package_install }}

Home Assistant environment files are managed:
  file.managed:
    - names:
      - {{ hass.lookup.paths.config_homeassistant }}:
        - source: {{ files_switch(
                        ["homeassistant.env", "homeassistant.env.j2"],
                        config=hass,
                        lookup="homeassistant environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- if hass.influxdb.install %}
      - {{ hass.lookup.paths.config_influxdb }}:
        - source: {{ files_switch(
                        ["influxdb.env", "influxdb.env.j2"],
                        config=hass,
                        lookup="influxdb environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- endif %}
{%- if "mariadb" == hass.db.type %}
      - {{ hass.lookup.paths.config_mariadb }}:
        - source: {{ files_switch(
                        ["mariadb.env", "mariadb.env.j2"],
                        config=hass,
                        lookup="mariadb environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- elif "postgres" == hass.db.type %}
      - {{ hass.lookup.paths.config_postgres }}:
        - source: {{ files_switch(
                        ["postgres.env", "postgres.env.j2"],
                        config=hass,
                        lookup="postgres environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- endif %}
    - mode: '0640'
    - user: root
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ hass.lookup.user.name }}
    - require_in:
      - Home Assistant is installed
    - context:
        hass: {{ hass | json }}

Home Assistant configuration is synced:
  file.recurse:
    - name: {{ hass.lookup.paths.config }}
    - source: {{ files_switch(
                    ["config"],
                    config=hass,
                    lookup="Home Assistant configuration is synced",
                 )
              }}
    - file_mode: '0644'
    - dir_mode: '0755'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - clean: {{ hass.config_management.clean_config }}
    - exclude_pat: {{ hass.lookup.config_sync_exclude | json }}
    - include_pat: {{ hass.lookup.config_sync_include | json }}
    # since home assistant uses Jinja for templates as well,
    # template rendering is turned off by default. you can either
    # use a different templating engine - e.g. mako - or wrap all
    # jinja blocks in raw/endraw tags
    - template: {{ hass.config_management.config_template_lang or "null" }}
    - require:
      - user: {{ hass.lookup.user.name }}
{%- if hass.config_management.config_template_lang %}
    - context:
        hass: {{ hass | json }}
{%- endif %}

Home Assistant base configuration is present:
  file.managed:
    - name: {{ hass.lookup.paths.config | path_join("configuration.yaml") }}
    - source: {{ files_switch(
                    ["configuration.yaml", "configuration.yaml.j2"],
                    config=hass,
                    lookup="Home Assistant base configuration is present",
                 )
              }}
    - template: jinja
    - mode: '0644'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - replace: {{ hass.config_management.manage_base_config }}
    - require:
      - user: {{ hass.lookup.user.name }}
    - context:
        hass: {{ hass | json }}
{%- if hass.db.type != "sqlite" %}
        db_url: {{ db_url }}
{%- endif %}

Home Asisstant base files are present:
  file.managed:
    - names:
      - {{ hass.lookup.paths.config | path_join("automations.yaml") }}:
        - contents: |
            # This file needs to exist for the frontend editor to work.
            []
      - {{ hass.lookup.paths.config | path_join("scenes.yaml") }}:
        - contents: |
            # This file needs to exist for the frontend editor to work.
            []
      - {{ hass.lookup.paths.config | path_join("scripts.yaml") }}:
        - contents: |
            # This file needs to exist for the frontend editor to work.
            {}
      - {{ hass.lookup.paths.config | path_join("secrets.yaml") }}:
        - mode: '0640'
    - mode: '0644'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - replace: false
    - onchanges:
      - Home Assistant base configuration is present

{%- if hass.config_management.secrets_manage and (
         hass.db.type != "sqlite" or
         hass.influxdb.install
       )
%}

Home Assistant managed secrets are synced:
  file.serialize:
    - name: {{ hass.lookup.paths.config | path_join("secrets.yaml") }}
    - serializer: yaml
    - merge_if_exists: true
    - mode: '0640'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}
    - dataset:
{%-   if hass.db.type != "sqlite" %}
        db_url: {{ db_url }}
{%-   endif %}
{%-   if hass.influxdb.install %}
        influx_token: {{ hass.influxdb.db_init.admin_token or salt["pillar.get"](hass.influxdb.db_init.admin_token_pillar) }}
{%-   endif %}
{%- endif %}

{%- if hass.config_management.secrets %}

Home Assistant secrets are synced:
  file.serialize:
    - name: {{ hass.lookup.paths.config | path_join("secrets.yaml") }}
    - serializer: yaml
    - merge_if_exists: {{ hass.config_management.secrets_manage }}
    - mode: '0640'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}
    - dataset: {{ hass.config_management.secrets | json }}
{%- endif %}

{%- if hass.config_management.secrets_pillar %}

Home Assistant secrets are synced from pillar:
  file.serialize:
    - name: {{ hass.lookup.paths.config | path_join("secrets.yaml") }}
    - dataset_pillar: {{ hass.config_management.secrets_pillar }}
    - serializer: yaml
    - merge_if_exists: {{ (hass.config_management.secrets_manage or hass.config_management.secrets) | to_bool }}
    - mode: '0640'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}
{%- endif %}

{%- if hass.config_management.ca_cert %}

Home Assistant CA certificate is managed:
  x509.pem_managed:
    - name: {{ hass.lookup.paths.config | path_join("salt_ca_root.pem") }}
    - text: {{ hass.config_management.ca_cert | json }}
    - mode: '0644'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}
{%- endif %}

{%- if hass.influxdb.install and hass.influxdb.config %}

InfluxDB config is managed:
  file.serialize:
    - name: {{ hass.lookup.paths.influxdb_config | path_join("config.yaml") }}
    - serializer: yaml
    - mode: '0644'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}
    - dataset: {{ hass.influxdb.config | json }}
    # do not restart everything when influxdb config changes
    # you will need to do that manually
    # - watch_in:
    #   - Home Assistant is installed
{%- endif %}
