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

{{- define "hcl-people-service.ldapSearchAttributes" -}}
  {{- print (join "," .Values.ldap.searchAttributes) }}
{{- end -}}

{{- define "hcl-people-service.ldapAttributeMapping" -}}
  {{- $attributes := list }}
  {{- range $key, $val := .Values.ldap.attributeMapping }}
    {{- if $val }}
      {{- $attributes = append $attributes (printf "%s=%s" $key $val) }}
    {{- end }}
  {{- end }}
  {{- print (join "," $attributes) }}
{{- end -}}

{{- define "hcl-people-service.createLdapSecret" -}}
  {{- print (ternary "true" "false" (and .Values.ldap.enabled (eq (include "hcl-people-service-useExistingLdapSecret" .) "false"))) }}
{{- end -}}

{{- define "hcl-people-service.ldapSecret" -}}
  {{- print (coalesce .Values.ldap.existingSecret (include "hcl-people-service.ldapSecretName" .)) }}
{{- end -}}

{{- define "hcl-people-service-useExistingLdapSecret" -}}
  {{- print (ternary "true" "false" (not ( empty .Values.ldap.existingSecret ))) }}
{{- end -}}

{{- define "hcl-people-service.ldapBindPassword" -}}
  {{- if eq (include "hcl-people-service-useExistingLdapSecret" .) "true" }}
    {{- print "" }}
  {{- else }}
    {{- print .Values.ldap.bindPassword }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.ldapBindPasswordSecretKey" -}}
  {{- $defaultKey:= "bindPassword" }}
  {{- if (include "hcl-people-service-useExistingLdapSecret" .) }}
    {{- print (default $defaultKey .Values.ldap.existingSecretBindPasswordKey) }}
  {{- else }}
    {{- print $defaultKey }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.ldapSecretData" -}}
  {{- if and .Values.ldap.enabled (not .Values.ldap.existingSecret) -}}
bindPassword: {{ include "hcl-people-service.ldapBindPassword" . | b64enc }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.validateLdapValues" -}}
  {{- if and .Values.ldap.enabled (empty .Values.ldap.host) -}}
    {{- fail "ldap.host is required when ldap.enabled is set to true" -}}
  {{- end -}}
{{- end -}}
