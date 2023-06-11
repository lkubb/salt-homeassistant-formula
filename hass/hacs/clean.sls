# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

HACS is absent:
  file.absent:
    - name: {{ hass.lookup.paths.config | path_join("custom_components", "hacs") }}
