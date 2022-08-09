# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - .package
  - .config
  - .service
{%- if hass.hacs.install %}
  - .hacs
{%- endif %}
