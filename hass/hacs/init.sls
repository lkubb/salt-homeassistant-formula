# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - .installed
{%- if hass.hacs.apply_yaml_config %}
  - .config
{%- endif %}
