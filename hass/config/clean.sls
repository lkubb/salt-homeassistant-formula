# vim: ft=sls

{#-
    Removes the configuration of the homeassistant, influxdb, mariadb, postgres containers
    and has a dependency on `hass.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - {{ sls_service_clean }}

Home Assistant environment files are absent:
  file.absent:
    - names:
      - {{ hass.lookup.paths.config_homeassistant }}
      - {{ hass.lookup.paths.config_influxdb }}
      - {{ hass.lookup.paths.config_mariadb }}
      - {{ hass.lookup.paths.config_postgres }}
      - {{ hass.lookup.paths.config | path_join("salt_ca_root.pem") }}
      - {{ hass.lookup.paths.influxdb_config }}
{%- if hass.install.remove_all_data_for_sure %}
      - {{ hass.lookup.paths.config }}
{%- endif %}
      - {{ hass.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
