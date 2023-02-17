# vim: ft=sls


{#-
    Stops the homeassistant, influxdb, mariadb, postgres container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

hass service is dead:
  compose.dead:
    - name: {{ hass.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if hass.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ hass.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
{%- endif %}

hass service is disabled:
  compose.disabled:
    - name: {{ hass.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if hass.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ hass.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
{%- endif %}
