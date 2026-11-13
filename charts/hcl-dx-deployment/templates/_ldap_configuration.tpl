{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021, 2025. All Rights Reserved. *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
  This file contains logic regarding LDAP configuration for Core and WebEngine
*/}}

{{/*
  Core: Determines if a configuration of LDAP is required or not, will default to false
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationEnabled" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf "true" -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines if a configuration of LDAP is required or not, will default to false
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationEnabled" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf "true" -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines host to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationHost" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf "%s-open-ldap" .Release.Name -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf .Values.configuration.core.ldap.host -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines host to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationHost" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf "%s-open-ldap" .Release.Name -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf .Values.configuration.webEngine.ldap.host -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines port to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationPort" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf (include "hcl-dx-deployment.ports.openldap.ldap" .) -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf (toString .Values.configuration.core.ldap.port) -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines port to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationPort" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf (include "hcl-dx-deployment.ports.openldap.ldap" .) -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf (toString .Values.configuration.webEngine.ldap.port) -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines suffix to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationSuffix" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf .Values.configuration.core.ldap.suffix -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines suffix to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationSuffix" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf .Values.configuration.webEngine.ldap.suffix -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines user to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationBindUser" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf .Values.security.openLdap.ldapUser -}},{{- printf .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf .Values.configuration.core.ldap.bindUser -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines user to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationBindUser" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf "cn=%s,%s" .Values.security.openLdap.ldapUser .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf .Values.configuration.webEngine.ldap.bindUser -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines user to use for LDAP configuration when custom LDAP secret is used
*/}}
{{- define "hcl-dx-deployment.customSecretLdapConfigurationBindUser" -}}
{{- $bindUser := "" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.openLdap.customLdapSecret "globalScope" . ) -}}
    {{- $openLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.security.openLdap.customLdapSecret)) }}
    {{- if $openLdapCustomSecret }}
      {{- $bindUser = (index $openLdapCustomSecret.data "username") }}
    {{- end -}}
    {{- printf $bindUser -}},{{- printf .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "bindUser" "bindPassword") "secretName" .Values.configuration.core.ldap.customLdapSecret "globalScope" . ) -}}
    {{- $configLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.configuration.core.ldap.customLdapSecret)) }}
    {{- if $configLdapCustomSecret }}
      {{- $bindUser = (index $configLdapCustomSecret.data "bindUser") }}
    {{- end -}}
    {{- printf $bindUser -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines user to use for LDAP configuration when custom LDAP secret is used
*/}}
{{- define "hcl-dx-deployment.customSecretWebEngineLdapConfigurationBindUser" -}}
{{- $bindUser := "" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.openLdap.customLdapSecret "globalScope" . ) -}}
    {{- $openLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.security.openLdap.customLdapSecret)) }}
    {{- if $openLdapCustomSecret }}
      {{- $bindUser = (index $openLdapCustomSecret.data "username") }}
    {{- end -}}
    {{- printf "cn=%s" (b64dec $bindUser) -}},{{- printf .Values.configuration.openLdap.suffix -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "bindUser" "bindPassword") "secretName" .Values.configuration.webEngine.ldap.customLdapSecret "globalScope" . ) -}}
    {{- $configLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.configuration.webEngine.ldap.customLdapSecret)) }}
    {{- if $configLdapCustomSecret }}
      {{- $bindUser = (index $configLdapCustomSecret.data "bindUser") }}
    {{- end -}}
    {{- printf "%s" (b64dec $bindUser) -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines password to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapConfigurationBindPassword" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- printf .Values.security.openLdap.ldapPassword -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- printf .Values.configuration.core.ldap.bindPassword -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines password to use for LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineConfigurationBindPassword" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- printf .Values.security.openLdap.ldapPassword -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- printf .Values.configuration.webEngine.ldap.bindPassword -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Core: Determines password to use for LDAP configuration when custom LDAP secret is used
*/}}
{{- define "hcl-dx-deployment.customSecretLdapConfigurationBindPassword" -}}
{{- $bindPassword := "" -}}
  {{- if eq .Values.configuration.core.ldap.type "dx" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.openLdap.customLdapSecret "globalScope" . ) -}}
    {{- $openLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.security.openLdap.customLdapSecret)) }}
    {{- if $openLdapCustomSecret }}
      {{- $bindPassword = (index $openLdapCustomSecret.data "password") }}
    {{- end -}}
    {{- printf $bindPassword -}}
  {{- else if eq .Values.configuration.core.ldap.type "other" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "bindUser" "bindPassword") "secretName" .Values.configuration.core.ldap.customLdapSecret "globalScope" . ) -}}
    {{- $configLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.configuration.core.ldap.customLdapSecret)) }}
    {{- if $configLdapCustomSecret }}
      {{- $bindPassword = (index $configLdapCustomSecret.data "bindPassword") }}
    {{- end -}}
    {{- printf $bindPassword -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: Determines password to use for LDAP configuration when custom LDAP secret is used
*/}}
{{- define "hcl-dx-deployment.customSecretWebEngineLdapConfigurationBindPassword" -}}
{{- $bindPassword := "" -}}
  {{- if eq .Values.configuration.webEngine.ldap.type "dx" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.openLdap.customLdapSecret "globalScope" . ) -}}
    {{- $openLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.security.openLdap.customLdapSecret)) }}
    {{- if $openLdapCustomSecret }}
      {{- $bindPassword = (index $openLdapCustomSecret.data "password") }}
    {{- end -}}
    {{- printf $bindPassword -}}
  {{- else if eq .Values.configuration.webEngine.ldap.type "other" -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "bindUser" "bindPassword") "secretName" .Values.configuration.webEngine.ldap.customLdapSecret "globalScope" . ) -}}
    {{- $configLdapCustomSecret := (lookup "v1" "Secret" .Release.Namespace (.Values.configuration.webEngine.ldap.customLdapSecret)) }}
    {{- if $configLdapCustomSecret }}
      {{- $bindPassword = (index $configLdapCustomSecret.data "bindPassword") }}
    {{- end -}}
    {{- printf $bindPassword -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  WebEngine: sslEnabled for the LDAP configuration
*/}}
{{- define "hcl-dx-deployment.ldapWebEngineSSLEnabled" -}}
  {{- if .Values.configuration.webEngine.ldap.sslEnabled -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}
