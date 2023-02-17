# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``hass`` meta-state
    in reverse order, i.e. stops the homeassistant, influxdb, mariadb, postgres services,
    removes their configuration and then removes their containers.
#}

include:
  - .service.clean
  - .config.clean
  - .package.clean
