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

{{- define "hcl-dx-deployment.contentComposerConfig" -}}
"dx.config.contentui.cors_origin": "{{ include "hcl-dx-deployment.contentComposerCorsOrigin" . }}"
"dx.config.contentui.external_ring_api_host": "{{ include "hcl-dx-deployment.externalAddonHost" . }}"
"dx.config.contentui.external_ring_api_port": "{{ include "hcl-dx-deployment.externalAddonPort" . }}"
"dx.config.contentui.portal_context_root": "{{ include "hcl-dx-deployment.contextRoot" . }}"
"dx.config.contentui.portal_host": "{{ include "hcl-dx-deployment.internalCoreHost" . }}"
"dx.config.contentui.portal_port": "{{ include "hcl-dx-deployment.internalCorePort" . }}"
"dx.config.contentui.ring_api_external_ssl_enabled": "{{ include "hcl-dx-deployment.externalAddonSsl" . }}"
"dx.config.contentui.ring_api_host": "{{ .Release.Name }}-ring-api"
"dx.config.contentui.ring_api_port": "{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }}"
"dx.config.contentui.ring_api_ssl_enabled": "false"
{{- end -}}