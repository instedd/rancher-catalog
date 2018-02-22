version: '2'

services:
  web: &app
    image: instedd/resourcemap:${RESMAP_VERSION}
    labels:
      io.rancher.container.pull_image: always
    environment:
      INSTEDD_THEME: https://a4b5cff76c528f65ea0a-27a040455636240d133755398736da07.ssl.cf2.rackcdn.com
      RAILS_ENV: production
      ELASTICSEARCH_URL: ${ELASTICSEARCH_URL}
      REDIS_URL: 'redis://redis:6379'
      DATABASE_URL: mysql2://${DATABASE_USER}:${DATABASE_PASS}@${DATABASE_HOST}/${DATABASE_NAME}
      SETTINGS__HOST: https://${HOSTNAME}
      SETTINGS__SMTP__ADDRESS: ${SMTP_HOST}
      SETTINGS__SMTP__PASSWORD: ${SMTP_PASS}
      SETTINGS__SMTP__PORT: ${SMTP_PORT}
      SETTINGS__SMTP__USER_NAME: ${SMTP_USER}

      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      SETTINGS__GOOGLE_MAPS_KEY: ${GOOGLE_MAPS_KEY}
      SETTINGS__NEWRELIC__LICENSE_KEY: ${NEWRELIC_LICENSE_KEY}

      # Nuntium configuration for SMS integration (optional)
      SETTINGS__NUNTIUM__URL: ${NUNTIUM_URL}
      SETTINGS__NUNTIUM__ACCOUNT: ${NUNTIUM_ACCOUNT}
      SETTINGS__NUNTIUM__APPLICATION: ${NUNTIUM_APPLICATION}
      SETTINGS__NUNTIUM__PASSWORD: ${NUNTIUM_PASSWORD}

      # GUISSO configuration
      GUISSO_ENABLED: ${GUISSO_ENABLED}
      {{- if eq .Values.GUISSO_ENABLED "true" }}
      GUISSO_URL: ${GUISSO_URL}
      GUISSO_CLIENT_ID: ${GUISSO_CLIENT_ID}
      GUISSO_CLIENT_SECRET: ${GUISSO_CLIENT_SECRET}
      {{- end }}
    volumes:
      - ${VOLUME_UPLOADS}:/app/public/uploads
      - ${VOLUME_IMPORT_WIZARD}:/app/tmp/import_wizard

  redis:
    image: redis:4.0-alpine
    volumes:
      - ${VOLUME_REDIS}:/data

  resque:
    <<: *app
    command: rake resque:work TERM_CHILD=1 FORK_PER_JOB=false

  resque-scheduler:
    <<: *app
    command: rake resque:scheduler

  db-migrate:
    image: instedd/resourcemap:${RESMAP_VERSION}
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: "true"
    command: rake db:migrate
    environment:
      DATABASE_URL: mysql2://${DATABASE_USER}:${DATABASE_PASS}@${DATABASE_HOST}/${DATABASE_NAME}
      REDIS_URL: 'redis://redis:6379'

volumes:
  {{ .Values.VOLUME_REDIS }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{ .Values.VOLUME_UPLOADS }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{ .Values.VOLUME_IMPORT_WIZARD }}:
    driver: ${VOLUME_DRIVER}
    external: true
