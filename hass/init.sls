# vim: ft=sls

{#-
    *Meta-state*.

    This installs the homeassistant, influxdb, mariadb, postgres containers,
    manages their configuration and starts their services.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - .package
  - .config
  - .service
{%- if hass.hacs.install %}
  - .hacs
{%- endif %}
