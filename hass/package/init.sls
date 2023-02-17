# vim: ft=sls

{#-
    Installs the homeassistant, influxdb, mariadb, postgres containers only.
    This includes creating systemd service units.
#}

include:
  - .install
