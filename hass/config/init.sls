# vim: ft=sls

{#-
    Manages the configuration of the homeassistant, influxdb, mariadb, postgres containers.
    Has a dependency on `hass.package`_.
#}

include:
  - .file
