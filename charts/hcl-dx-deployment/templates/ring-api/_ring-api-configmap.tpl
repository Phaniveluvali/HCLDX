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

{{- define "hcl-dx-deployment.ringApiConfig" -}}
"dx.config.experienceapi.cors_origin": "{{ include "hcl-dx-deployment.ringApiCorsOrigin" . }}"
"dx.config.experienceapi.portal_context_root": "{{ include "hcl-dx-deployment.contextRoot" . }}"
"dx.config.experienceapi.portal_host": "{{ include "hcl-dx-deployment.internalCoreHost" . }}"
"dx.config.experienceapi.portal_personalized_home": "{{ .Values.networking.core.personalizedHome }}"
"dx.config.experienceapi.portal_port": "{{ include "hcl-dx-deployment.internalCorePort" . }}"
"dx.config.experienceapi.portal_ssl_enabled": "{{ include "hcl-dx-deployment.internalCoreSsl" . }}"
{{- end -}}