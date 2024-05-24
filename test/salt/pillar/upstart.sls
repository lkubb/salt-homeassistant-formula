# vim: ft=yaml
---
hass:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: false
      pod_args: null
      project_name: homeassistant
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/homeassistant
      compose: docker-compose.yml
      config_homeassistant: homeassistant.env
      config_influxdb: influxdb.env
      config_mariadb: mariadb.env
      config_postgres: postgres.env
      ca_cert: additional_ca/salt_ca.pem
      config: config
      influxdb_config: influxdb_config
      influxdb_data: influxdb_data
      mariadb: mariadb
      postgres: postgres
    user:
      groups: ['dialout']
      home: null
      name: homeassistant
      shell: /usr/sbin/nologin
      uid: null
      gid: null
    bluetooth:
      pkgs:
        - dbus-broker
        - bluez
    config_sync_include: []
    config_sync_exclude:
      - .HA_VERSION
      - E@\.storage(/.*)?$
      - E@\.cloud(/.*)?$
      - E@backups(/.*)?$
      - E@custom_components(/.*)?$
      - E@deps(/.*)?$
      - E@tts(/.*)?$
      - E@.*.log(\.fault)?$
      - E@additional_ca(/.*\.pem)?$
      - automations.yaml
      - blueprints/automation/homeassistant/motion_light.yaml
      - blueprints/automation/homeassistant/notify_leaving_zone.yaml
      - blueprints/script/homeassistant/confirmable_notification.yaml
      - scripts.yaml
      - secrets.yaml
      - scenes.yaml
      - '*.log*'
    containers:
      homeassistant:
        image: ghcr.io/home-assistant/home-assistant:stable
      influxdb:
        image: docker.io/library/influxdb:latest
      mariadb:
        image: docker.io/library/mariadb:latest
      postgres:
        image: docker.io/library/postgres:latest
    dbus_path: /run/dbus
    hacs:
      hash: ''
      repo: hacs/integration
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
    podman_api: true
  bluetooth:
    enable: false
  config_base:
    automation: '!include automations.yaml'
    default_config: null
    homeassistant:
      allowlist_external_dirs: []
      currency: USD
      elevation: 0
      latitude: 0
      longitude: 0
      name: Home Assistant
      time_zone: Etc/UTC
      unit_system: metric
    scene: '!include scenes.yaml'
    script: '!include scripts.yaml'
  config_management:
    ca_cert: null
    clean_config: false
    config_template_lang: null
    manage_base_config: false
    secrets: {}
    secrets_manage: true
    secrets_pillar: ''
  container:
    dbus: false
    devices: []
    environment: {}
  db:
    autoupgrade: true
    extra_params: {}
    name: hass
    password: null
    password_pillar: null
    socket: false
    type: sqlite
    user: hass
  hacs:
    apply_yaml_config: false
    config:
      appdaemon: true
      country: null
      experimental: false
      netdaemon: true
      release_limit: 5
      sidepanel_icon: mdi:alpha-c-box
      sidepanel_title: Community
      token: '!secret github_token'
    install: true
  influxdb:
    config: {}
    db_init:
      admin_token: null
      admin_token_pillar: null
      bucket: hass
      org: hass
      password: null
      password_pillar: null
      retention: null
      user: hass
    install: false
  firewall:
    manage: false
    port: 8123
  salt_mod_github_releases: true

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://hass/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   hass-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Home Assistant environment file is managed:
        - hass.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
