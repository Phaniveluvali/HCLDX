{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2024. All Rights Reserved.       *
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

{{- define "hcl-dx-deployment.peopleServiceWebResourcesUri" -}}
  {{- if eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true" }}
    {{- printf "http://%s-peopleservice:%s%s" .Release.Name (.Values.peopleservice.containerPorts.http | toString ) .Values.peopleservice.networking.contextRoot.ui }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}