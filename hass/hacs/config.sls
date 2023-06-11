# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_hacs_installed = tplroot ~ ".hacs.installed" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_hacs_installed }}

HACS YAML configuration is managed:
  file.managed:
    - name: {{ hass.lookup.paths.config | path_join("hacs.yaml") }}
    - source: {{ files_switch(
                    ["hacs.yaml", "hacs.yaml.j2"],
                    config=hass,
                    lookup="HACS YAML configuration is managed",
                 )
              }}
    - template: jinja
    - mode: '0644'
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - replace: {{ hass.config_management.manage_base_config }}
    - require:
      - user: {{ hass.lookup.user.name }}
      - sls: {{ sls_hacs_installed }}
    - watch_in:
      - Home Assistant is installed
    - context:
        hass: {{ hass | json }}
