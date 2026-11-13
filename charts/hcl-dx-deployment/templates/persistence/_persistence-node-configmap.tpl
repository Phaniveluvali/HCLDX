{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021. All Rights Reserved.       *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
  CONFIG MAP KEYS AND VALUES MUST BE ENCLOSED IN DOUBLE QUOTES
  CONFIG MAP KEYS MUST BE SORTED ALPHABETICALLY
  ENTRIES MUST BE TRIMMED MANUALLY + 1 WHITESPACE AFTER COLON
*/}}

{{- define "hcl-dx-deployment.persistenceNodeConfig" -}}
"dam.config.dam.persistence.postgres_db": "{{ include "hcl-dx-deployment.damDatabaseName" . }}"
"dam.config.dam.persistence.postgres_max_connections": "1000"
"dam.config.dam.persistence.postgres_wal_keep_segments": "64"
"dam.config.dam.persistence.postgres_wal_senders": "5"
"dam.config.dam.persistence.replication_db": "repmgr"
"dam.config.dam.persistence.repmgr_port_number": "{{ include "hcl-dx-deployment.ports.persistence.repmgr" . }}"
"dam.config.dam.persistence.synchronous_commit": "remote_apply"
"dam.config.dam.persistence.synchronous_standby_names": "{{ include "hcl-dx-deployment.persistence.synchronousStandbyNames" . }}"
"dam.config.dam.persistence.validation_sleep_timer": "{{ .Values.configuration.persistence.validationSleepTimer | int}}"
{{- end -}}
