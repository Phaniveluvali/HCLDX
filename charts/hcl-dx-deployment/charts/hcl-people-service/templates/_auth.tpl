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
 
{{- define "hcl-people-service.createOidcSecret" -}}
  {{- print (ternary "true" "false" (and (eq (.Values.configuration.authStrategy | lower) "oidc") (eq (include "hcl-people-service-useExistingOidcSecret" .) "false"))) }}
{{- end -}}

{{- define "hcl-people-service.oidcSecret" -}}
  {{- print (coalesce .Values.configuration.oidc.existingSecret (include "hcl-people-service.oidcSecretName" .)) }}
{{- end -}}

{{- define "hcl-people-service-useExistingOidcSecret" -}}
  {{- print (ternary "false" "true" ( empty .Values.configuration.oidc.existingSecret )) }}
{{- end -}}

{{- define "hcl-people-service.clientSecret" -}}
  {{- if eq (include "hcl-people-service-useExistingOidcSecret" .) "true" }}
    {{- print "" }}
  {{- else }}
    {{- print .Values.configuration.oidc.clientSecret }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.clientSecretKey" -}}
  {{- $defaultKey:= "clientSecret" }}
  {{- if eq (include "hcl-people-service-useExistingOidcSecret" .) "true" }}
    {{- print (default $defaultKey .Values.configuration.oidc.existingSecretClientSecretKey) }}
  {{- else }}
    {{- print $defaultKey }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.oidcSecretData" -}}
  {{- if (eq (include "hcl-people-service.createOidcSecret" .) "true") -}}
clientSecret: {{ include "hcl-people-service.clientSecret" . | b64enc }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.createJwtSecret" -}}
  {{- print (ternary "true" "false" (empty .Values.configuration.jwt.existingSecret )) }}
{{- end -}}

{{- define "hcl-people-service-useExistingJwtSecret" -}}
  {{- print (ternary "false" "true" ( empty .Values.configuration.jwt.existingSecret )) }}
{{- end -}}

{{- define "hcl-people-service.jwtSecret" -}}
  {{- print (coalesce .Values.configuration.jwt.existingSecret (include "hcl-people-service.jwtSecretName" .)) }}
{{- end -}}

{{- define "hcl-people-service.jwtSecretValue" -}}
  {{- if eq (include "hcl-people-service-useExistingJwtSecret" .) "true" }}
    {{- print "" }}
  {{- else }}
    {{- print .Values.configuration.jwt.secret }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.jwtSecretKey" -}}
  {{- $defaultKey:= "jwtSecret" }}
  {{- if eq (include "hcl-people-service-useExistingJwtSecret" .) "true" }}
    {{- print ( default $defaultKey .Values.configuration.jwt.existingSecretJwtSecretKey ) }}
  {{- else }}
    {{- print $defaultKey }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.jwtSecretData" -}}
  {{- if (eq (include "hcl-people-service.createJwtSecret" .) "true") -}}
jwtSecret: {{ include "hcl-people-service.jwtSecretValue" . | b64enc }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.validateAuthValues" -}}
  {{- if (eq (.Values.configuration.authStrategy | lower) "oidc") -}}
    {{- if or (empty .Values.configuration.oidc.clientId) (empty .Values.configuration.oidc.clientSecret) (empty .Values.configuration.oidc.redirectURI) -}}
      {{- fail "configuration.oidc.clientId, configuration.oidc.clientSecret and configuration.oidc.redirectURI are required when configuration.authStrategy is oidc" -}}
    {{- end -}}
  {{- else -}}
    {{- if (eq (.Values.configuration.authStrategy | lower) "dx") -}}
      {{- if or (empty .Values.configuration.dx.userValidationEndpoint) (empty .Values.configuration.dx.sessionCookieName) (empty .Values.configuration.dx.currentUserAccessEndpoint) (empty .Values.configuration.dx.userAccessPrivilegedRoles) -}}
        {{- fail "configuration.dx.userValidationEndpoint, configuration.dx.sessionCookieName, configuration.dx.currentUserAccessEndpoint, configuration.dx.userAccessPrivilegedRoles are required when configuration.authStrategy is dx" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
