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

{{- define "hcl-people-service.databaseConfig" -}}
{{- with .Values.externalDatabase -}}
{{- $defaultUsernameKey := "db-user" -}}
{{- $defaultPasswordKey := "db-password" -}}
- name: PG_HOST
  value: {{ .host }}
- name: PG_PORT
  value: {{ .port | toString | quote }}
- name: DB_NAME
  value: {{ .database }}
- name: PG_USERNAME
  valueFrom:
    secretKeyRef:
  {{- if empty .existingSecret }}
      name: {{ include "hcl-people-service.databaseSecretName" $ }}
      key: {{ $defaultUsernameKey }}
  {{- else }}
      name: {{ .existingSecret }}
      key: {{ coalesce .existingSecretUserKey $defaultUsernameKey }}
  {{- end }}
- name: PG_PASSWORD
  valueFrom:
    secretKeyRef:
      {{- if empty .existingSecret }}
      name: {{ include "hcl-people-service.databaseSecretName" $ }}
      key: {{ $defaultPasswordKey }}
      {{- else }}
      name: {{ .existingSecret }}
      key: {{ coalesce .existingSecretPasswordKey $defaultPasswordKey }}
      {{- end }}
{{- end }}
{{- end -}}
