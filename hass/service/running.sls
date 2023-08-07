# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - {{ sls_config_file }}

Home Assistant service is enabled:
  compose.enabled:
    - name: {{ hass.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if hass.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ hass.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Home Assistant is installed
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
{%- endif %}

Home Assistant service is running:
  compose.running:
    - name: {{ hass.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if hass.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ hass.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
{%- endif %}
    - watch:
      - Home Assistant is installed

{%- if hass.firewall.manage and grains["os_family"] == "RedHat" %}

Home Assistant service is known:
  firewalld.service:
    - name: hass
    - ports:
      - {{ hass.firewall.port }}/tcp
    - require:
      - Home Assistant service is running

Home Assistant ports are open:
  firewalld.present:
    - name: public
    - services:
      - hass
    - require:
      - Home Assistant service is known
{%- endif %}
