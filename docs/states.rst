Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``hass``
^^^^^^^^
*Meta-state*.

This installs the homeassistant, influxdb, mariadb, postgres containers,
manages their configuration and starts their services.


``hass.package``
^^^^^^^^^^^^^^^^
Installs the homeassistant, influxdb, mariadb, postgres containers only.
This includes creating systemd service units.


``hass.config``
^^^^^^^^^^^^^^^
Manages the configuration of the homeassistant, influxdb, mariadb, postgres containers.
Has a dependency on `hass.package`_.


``hass.service``
^^^^^^^^^^^^^^^^
Starts the homeassistant, influxdb, mariadb, postgres container services
and enables them at boot time.
Has a dependency on `hass.config`_.


``hass.hacs``
^^^^^^^^^^^^^



``hass.hacs.config``
^^^^^^^^^^^^^^^^^^^^



``hass.hacs.installed``
^^^^^^^^^^^^^^^^^^^^^^^



``hass.clean``
^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``hass`` meta-state
in reverse order, i.e. stops the homeassistant, influxdb, mariadb, postgres services,
removes their configuration and then removes their containers.


``hass.package.clean``
^^^^^^^^^^^^^^^^^^^^^^
Removes the homeassistant, influxdb, mariadb, postgres containers
and the corresponding user account and service units.
Has a depency on `hass.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``hass.config.clean``
^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the homeassistant, influxdb, mariadb, postgres containers
and has a dependency on `hass.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``hass.service.clean``
^^^^^^^^^^^^^^^^^^^^^^
Stops the homeassistant, influxdb, mariadb, postgres container services
and disables them at boot time.


``hass.hacs.clean``
^^^^^^^^^^^^^^^^^^^



