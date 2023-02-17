# vim: ft=sls

{#-
    Starts the homeassistant, influxdb, mariadb, postgres container services
    and enables them at boot time.
    Has a dependency on `hass.config`_.
#}

include:
  - .running
