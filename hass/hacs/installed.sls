# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as hass with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

HACS is installed:
  archive.extracted:
    - name: {{ hass.lookup.paths.config | path_join("custom_components", "hacs") }}
    - source: {{ files_switch(
                    ["hacs.zip"],
                    config=hass,
                    lookup="HACS is installed",
                 )
              }}
{%- if hass.salt_mod_github_releases %}
      - __slot__:salt:github_releases.get_asset({{ hass.lookup.hacs.repo }}).download
{%- endif %}
{%- if hass.lookup.hacs.hash %}
    - source_hash: {{ hass.lookup.hacs.hash }}
{%- else %}
    - skip_verify: true
{%- endif %}
    - clean_parent: true
    - enforce_toplevel: false
    - user: {{ hass.lookup.user.name }}
    - group: {{ hass.lookup.user.name }}
    - require:
      - user: {{ hass.lookup.user.name }}
