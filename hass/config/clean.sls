# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - {{ sls_service_clean }}

# This does not lead to the containers/services being rebuilt
# and thus differs from the usual behavior
Home Assistant environment files are absent:
  file.absent:
    - names:
      - {{ hass.lookup.paths.config_homeassistant }}
      - {{ hass.lookup.paths.config_influxdb }}
      - {{ hass.lookup.paths.config_mariadb }}
      - {{ hass.lookup.paths.config_postgres }}
      - {{ hass.lookup.paths.influxdb_config }}
{%- if hass.install.remove_all_data_for_sure %}
      - {{ hass.lookup.paths.config }}
{%- endif %}
      - {{ hass.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
