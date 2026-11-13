{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021. All Rights Reserved.       *
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

{{- define "hcl-dx-deployment.openLdapConfig" -}}
"dx.openldap.country": "{{ .Values.configuration.openLdap.country }}"
"dx.openldap.ldap_org": "{{ .Values.configuration.openLdap.org }}"
"dx.openldap.ldap_suffix": "{{ .Values.configuration.openLdap.suffix }}"
{{- end -}}