{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021, 2025. All Rights Reserved. *
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

{{- define "hcl-dx-deployment.runtimeControllerConfig" -}}
{{/* comma separated list of the suffix of the deployment/statefulset names which should be monitored. */}}
"runtimecontroller.config.imageTagChecksum": "{{ .Values.images.tags.runtimeController | sha256sum }}"
"runtimecontroller.config.runtime_controller_lease_expiry_time": "{{ .Values.configuration.runtimeController.leaderElection.leaseExpiryTime | int }}"
"runtimecontroller.config.runtime_controller_lease_polling_time": "{{ .Values.configuration.runtimeController.leaderElection.leasePollingTime | int }}"
{{- end -}}