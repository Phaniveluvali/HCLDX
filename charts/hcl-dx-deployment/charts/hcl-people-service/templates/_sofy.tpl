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
Create ambassador id
*/}}
{{- define "hcl-people-service.ambassadorID" -}}
{{- $global := .Values.global }}
    {{- if .Values.global.emissaryID }}
      {{- printf $global.emissaryID -}}
    {{- else if $global.ambassadorID -}}
      {{- printf $global.ambassadorID -}}
    {{- end -}}
{{- end -}}

{{/*
Check is SoFy deployment
*/}}
{{- define "hcl-people-service.isSofyDeployment" -}}
  {{- if .Values.global }}
    {{- if (include "hcl-people-service.ambassadorID" .) }}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}
