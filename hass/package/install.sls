# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{%- set extmod_list = salt["saltutil.list_extmods"]() %}

Custom modules are present for hass:
  saltutil.sync_all:
    - refresh: true
    - unless:
      - '{{ ("compose" in extmod_list.get("states", [])) | lower }}'
{%- if hass.salt_mod_github_releases %}
      - '{{ ("github_releases" in extmod_list.get("states", [])) | lower }}'
{%- endif %}

Home Assistant user account is present:
  user.present:
{%- for param, val in hass.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ hass.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Home Assistant user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ hass.lookup.user.name }}
    - enable: {{ hass.install.rootless }}
    - require:
      - user: {{ hass.lookup.user.name }}

Home Assistant paths are present:
  file.directory:
    - names:
      - {{ hass.lookup.paths.base }}
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ hass.lookup.user.name }}

{%- if hass.install.podman_api %}

Home Assistant podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ hass.lookup.user.name }}
    - require:
      - Home Assistant user session is initialized at boot

Home Assistant podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ hass.lookup.user.name }}
    - require:
      - Home Assistant user session is initialized at boot
{%- endif %}

Home Assistant compose file is managed:
  file.managed:
    - name: {{ hass.lookup.paths.compose }}
    - source: {{ files_switch(
                    ["docker-compose.yml", "docker-compose.yml.j2"],
                    config=hass,
                    lookup="Home Assistant compose file is present",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ hass.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        hass: {{ hass | json }}

{%- if hass.bluetooth.enable %}

Bluez and dbus-broker are installed for Home Assistant:
  pkg.installed:
    - pkgs: {{ hass.lookup.bluetooth.pkgs | json }}
    - require_in:
      - Home Assistant is installed
{%- endif %}

Home Assistant is installed:
  compose.installed:
    - name: {{ hass.lookup.paths.compose }}
{%- for param, val in hass.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in hass.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- if hass.install.rootless and hass.container.dbus %}
    - podman_create_args:
      - userns: keep-id
{%- endif %}
    - watch:
      - file: {{ hass.lookup.paths.compose }}
{%- if hass.install.rootless %}
    - user: {{ hass.lookup.user.name }}
    - require:
      - user: {{ hass.lookup.user.name }}
{%- endif %}

{%- if hass.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Home Assistant:
{%-   if hass.install.rootless %}
  compose.systemd_service_{{ "enabled" if hass.install.autoupdate_service else "disabled" }}:
    - user: {{ hass.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if hass.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
