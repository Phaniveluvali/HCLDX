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
This file compiles helpers regarding the overall deployment
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "hcl-people-service.name" -}}
  {{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "hcl-people-service.chartName" -}}
  {{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hcl-people-service.chartFullname" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified name for people-service.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hcl-people-service.fullname" -}}
  {{- if contains .Chart.Name .Release.Name }}
    {{- .Release.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- if contains "hcl-" .Release.Name }}
      {{- printf "%s-%s" .Release.Name (replace "hcl-" "" .Chart.Name) | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.pvcName" -}}
  {{- printf "%s-data" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "hcl-people-service.databaseSecretName" -}}
  {{- printf "%s-database" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "hcl-people-service.jwtSecretName" -}}
  {{- printf "%s-jwt" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "hcl-people-service.oidcSecretName" -}}
  {{- printf "%s-oidc" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "hcl-people-service.ldapSecretName" -}}
  {{- printf "%s-ldap" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "logging-sidecar.audit.fullname" -}}
  {{- printf "%s-audit-log" (include "hcl-people-service.fullname" .) }}
{{- end -}}

{{- define "logging-sidecar.sync.fullname" -}}
  {{- printf "%s-sync-log" (include "hcl-people-service.fullname" .) }}
{{- end -}}
