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

{{- define "hcl-people-service.searchMiddlewareEnabled" -}}
  {{- if .Values.configuration.search.middleware.enabled -}}
    {{- print "true" }}
  {{- else }}
    {{- print "false" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.shouldCreateSearchMiddlewarePushAdminSecret" -}}
  {{- if and (not .Values.configuration.integration.dx) .Values.configuration.search.middleware.enabled }}
    {{- if empty .Values.configuration.search.middleware.existingPushAdminSecret }}
      {{- print "true" }}
    {{- else -}}
      {{- print "false" }}
    {{- end }}
  {{- else -}}
    {{- print "false" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.searchMiddlewarePushAdminSecretName" -}}
  {{- if eq (include "hcl-people-service.shouldCreateSearchMiddlewarePushAdminSecret" .) "true" }}
    {{- printf "%s-search-middleware-push-admin" (include "hcl-people-service.fullname" .) }}
  {{- else if .Values.configuration.integration.dx }}
    {{- printf "%s-dam-search-middleware-push-admin" .Release.Name }}
  {{- else if (not (empty .Values.configuration.search.middleware.existingPushAdminSecret)) }}
    {{- printf "%s" .Values.configuration.search.middleware.existingPushAdminSecret }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.searchMiddlewarePushAdminSecretData" -}}
  # Initialize all variables with the default value
  {{- $username := "" }}
  {{- $password := "" }}
  {{- if eq (include "hcl-people-service.shouldCreateSearchMiddlewarePushAdminSecret" .) "true" }}
    {{- $username = .Values.configuration.search.middleware.pushAdminUser | b64enc }}
    {{- $password = .Values.configuration.search.middleware.pushAdminPassword | b64enc }}
  {{- end }}
  {{- if and $username $password }}
username: {{ $username }}
password: {{ $password }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}
