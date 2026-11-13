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
Common labels
*/}}
{{- define "hcl-people-service.labels" -}}
release: "{{ .Release.Name }}"
helm.sh/chart: {{ include "hcl-people-service.chartFullname" . }}
{{ include "hcl-people-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "hcl-people-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hcl-people-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
