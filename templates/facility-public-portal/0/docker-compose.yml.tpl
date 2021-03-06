version: '2'

services:
  web: &app
    image: instedd/vitalwave:${FPP_VERSION}
    labels:
      io.rancher.container.pull_image: always
    environment:
      {{- if eq .Values.EXTERNAL_DATABASE "true" }}
      DATABASE_URL: postgres://${DATABASE_USER}:${DATABASE_PASS}@${DATABASE_HOST}/${DATABASE_NAME}
      {{- else }}
      DATABASE_URL: postgres://facilities@db/facilities
      {{- end }}

      ELASTICSEARCH_URL: ${ELASTICSEARCH_URL}
      ELASTICSEARCH_INDEX: ${ELASTICSEARCH_INDEX}

      FAKE_USER_POSITION: ${FAKE_USER_POSITION}

      SECRET_KEY_BASE: ${SECRET_KEY_BASE}

      SETTINGS__ADMIN_USER: ${ADMIN_USER}
      SETTINGS__ADMIN_PASS: ${ADMIN_PASS}

      SETTINGS__REPORT_EMAIL_TO: ${REPORT_EMAIL_TO}

      SETTINGS__SMTP_SETTINGS__ADDRESS: ${SMTP_HOST}
      SETTINGS__SMTP_SETTINGS__PASSWORD: ${SMTP_PASS}
      SETTINGS__SMTP_SETTINGS__PORT: ${SMTP_PORT}
      SETTINGS__SMTP_SETTINGS__USER_NAME: ${SMTP_USER}
    volumes:
      - ${VOLUME_SETTINGS}:/app/config/settings
      - ${VOLUME_IMPORT_DATA}:/app/data
      - ${VOLUME_PICTURES}:/app/public/pictures
    {{- if .Values.WEB_MEM_LIMIT }}
    mem_limit: ${WEB_MEM_LIMIT}
    {{- end }}
    {{- if .Values.WEB_MEM_RESERVATION }}
    mem_reservation: ${WEB_MEM_RESERVATION}
    {{- end }}

  db-migrate:
    <<: *app
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: "true"
    command: rake db:migrate

  {{- if eq .Values.EXTERNAL_DATABASE "false" }}
  db:
    image: postgres:9.5
    environment:
      POSTGRES_DB: facilities
      POSTGRES_USER: facilities
    volumes:
    - ${VOLUME_PG_DATA}:/var/lib/postgresql/data
    {{- if .Values.DB_MEM_LIMIT }}
    mem_limit: ${DB_MEM_LIMIT}
    {{- end }}
    {{- if .Values.DB_MEM_RESERVATION }}
    mem_reservation: ${DB_MEM_RESERVATION}
    {{- end }}
  {{- end }}

volumes:
  {{ .Values.VOLUME_IMPORT_DATA }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{ .Values.VOLUME_SETTINGS }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{ .Values.VOLUME_PICTURES }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{- if eq .Values.EXTERNAL_DATABASE "false" }}
  {{ .Values.VOLUME_PG_DATA }}:
    driver: ${VOLUME_DRIVER}
    external: true
  {{- end }}
