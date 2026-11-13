{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2023. All Rights Reserved.       *
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

{{- define "hcl-dx-deployment.remoteSearchConfig" -}}
"remotesearch.config.deployment_type": "helm"
"remotesearch.config.ldap_enabled": "{{ include "hcl-dx-deployment.ldapConfigurationEnabled" . }}"
"remotesearch.config.metrics_enabled": "{{ .Values.metrics.remoteSearch.scrape }}"
"remotesearch.config.remote_search_auto_config_core_wait_time": "{{ .Values.configuration.remoteSearch.coreWaitTime | int }}"
"remotesearch.config.remote_search_auto_config_enabled": "{{ include "hcl-dx-deployment.configureRemoteSearch" . }}"
"remotesearch.config.remote_search_auto_config_job_retry_limit": "{{ .Values.configuration.remoteSearch.remoteSearchConfigTries | int}}"
"remotesearch.config.remote_search_auto_config_rs_wait_time": "{{ .Values.configuration.remoteSearch.remoteSearchWaitTime | int }}"
{{- end -}}