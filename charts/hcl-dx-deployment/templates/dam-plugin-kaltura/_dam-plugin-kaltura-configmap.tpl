{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2022. All Rights Reserved.       *
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

{{- define "hcl-dx-deployment.damPluginKalturaConfig" -}}
"dam.config.dam.damPluginKaltura.cors_origin": "{{ include "hcl-dx-deployment.damPluginKalturaCorsOrigin" . }}"
"dam.config.dam.kaltura_config.json": |
  {
   "partnerId": "{{ .Values.configuration.damPluginKaltura.partnerId }}",
   "thumbnailUrlPattern": "{{ .Values.configuration.damPluginKaltura.thumbnailUrlPattern }}"
  }
{{- end -}}