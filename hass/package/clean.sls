# vim: ft=sls

{#-
    Removes the homeassistant, influxdb, mariadb, postgres containers
    and the corresponding user account and service units.
    Has a depency on `hass.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}

include:
  - {{ sls_config_clean }}

{%- if hass.install.autoupdate_service %}

Podman autoupdate service is disabled for Home Assistant:
{%-   if hass.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ hass.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Home Assistant is absent:
  compose.removed:
    - name: {{ hass.lookup.paths.compose }}
    - volumes: {{ hass.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if hass.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ hass.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Home Assistant compose file is absent:
  file.absent:
    - name: {{ hass.lookup.paths.compose }}
    - require:
      - Home Assistant is absent

{%- if hass.install.podman_api %}

Home Assistant podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman
    - user: {{ hass.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ hass.lookup.user.name }}

Home Assistant podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman
    - user: {{ hass.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ hass.lookup.user.name }}
{%- endif %}

Home Assistant user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ hass.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ hass.lookup.user.name }}

Home Assistant user account is absent:
  user.absent:
    - name: {{ hass.lookup.user.name }}
    - purge: {{ hass.install.remove_all_data_for_sure }}
    - require:
      - Home Assistant is absent
    - retry:
        attempts: 5
        interval: 2

{%- if hass.install.remove_all_data_for_sure %}

Home Assistant paths are absent:
  file.absent:
    - names:
      - {{ hass.lookup.paths.base }}
    - require:
      - Home Assistant is absent
{%- endif %}
