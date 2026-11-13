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
Create image pull secrets
*/}}
{{- define "hcl-people-service.imagePullSecret" -}}
imagePullSecrets:
  {{- if (.Values.global) }}
    {{- if (.Values.global.hclImagePullSecret) }}
  - name: {{ .Values.global.hclImagePullSecret }}
    {{- end }}
  {{- end }}
  {{- if (.Values.image) }}
    {{- if (.Values.image.imagePullSecrets) }}
  {{- toYaml (.Values.image.imagePullSecrets) | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
People service image templates
*/}}
{{/*
Create image repository path
*/}}
{{- define "hcl-people-service.imageRegistry" -}}
  {{- if (include "hcl-people-service.ambassadorID" .) }}
    {{- if eq .Values.global.hclImageRegistry "hclcr.io/sofy" -}}
      hclcr.io
    {{- else if eq .Values.global.hclImageRegistry "gcr.io/blackjack-209019" -}}
      gcr.io/blackjack-209019/services
    {{- else if eq .Values.global.hclPreviewImageRegistry "hclcr.io/sofy-hcl-users" -}}
      hclcr.io/sofy-hcl-users/services
    {{- else -}}
      {{- printf .Values.global.hclImageRegistry }}
    {{- end -}}
  {{- else -}}
    {{- printf .Values.image.registry }}
  {{- end -}}
{{- end -}}

{{/*
Create image URI
*/}}
{{- define "hcl-people-service.image" -}}
  {{- $registry := include "hcl-people-service.imageRegistry" . }}
  {{- if $registry }}
    {{- printf "%s/%s:%s" $registry .Values.image.repository .Values.image.tag }}
  {{- else }}
    {{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
  {{- end }}
{{- end -}}

{{/*
Logging sidecar image templates
*/}}
{{/*
Create image repository path
*/}}
{{- define "logging-sidecar.imageRegistry" -}}
  {{- if (include "hcl-people-service.ambassadorID" .) }}
    {{- if eq .Values.global.hclImageRegistry "hclcr.io/sofy" -}}
      hclcr.io
    {{- else if eq .Values.global.hclImageRegistry "gcr.io/blackjack-209019" -}}
      gcr.io/blackjack-209019/services
    {{- else if eq .Values.global.hclPreviewImageRegistry "hclcr.io/sofy-hcl-users" -}}
      hclcr.io/sofy-hcl-users/services
    {{- else -}}
      {{- printf .Values.global.hclImageRegistry }}
    {{- end -}}
  {{- else -}}
    {{- printf .Values.logging.sidecar.image.registry }}
  {{- end -}}
{{- end -}}
{{/*
Create image URI
*/}}
{{- define "logging-sidecar.image" -}}
  {{- $registry := include "logging-sidecar.imageRegistry" . }}
  {{- if $registry }}
    {{- printf "%s/%s:%s" $registry .Values.logging.sidecar.image.repository .Values.logging.sidecar.image.tag }}
  {{- else }}
    {{- printf "%s:%s" .Values.logging.sidecar.image.repository .Values.logging.sidecar.image.tag }}
  {{- end }}
{{- end -}}