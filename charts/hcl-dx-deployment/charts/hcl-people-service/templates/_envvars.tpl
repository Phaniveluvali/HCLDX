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

{{- define "hcl-people-service.envVars" -}}
NODE_ENV: {{ ternary "production" "development" .Values.configuration.production | quote }}
  {{- if not .Values.configuration.production }}
NODE_TLS_REJECT_UNAUTHORIZED: "0"
  {{- end }}
DEBUG: {{ .Values.logging.level | quote }}
EXTERNAL_HOST: {{ include "hcl-people-service.externalHostUrl" . | quote }}
HTTP_SCHEME: {{ include "hcl-people-service.scheme" . | quote }}
API_SERVICE_CONTEXT: {{ .Values.networking.contextRoot.api | quote }}
CLIENT_CONTEXT: {{ .Values.networking.contextRoot.ui | quote }}
JWT_TOKEN_EXPIRY: {{ int .Values.configuration.jwt.tokenExpiration | quote }}
AUTH_STRATEGY: {{ .Values.configuration.authStrategy | quote }}
USER_UNIQUE_IDENTIFIER: {{ .Values.configuration.uniqueUserIdentifier | quote }}
PROFILE_READONLY_FIELDS_STRING: {{ include "hcl-people-service.readonlyFields" . | quote }}
BASE_CUSTOM_FIELDS_STRING: {{ include "hcl-people-service.customFields" . | quote }}
{{- if eq (.Values.configuration.authStrategy | lower ) "oidc" }}
OIDC_ISSUER: {{ .Values.configuration.oidc.issuer | quote }}
OIDC_CLIENT_ID: {{ .Values.configuration.oidc.clientId | quote }}
OIDC_REDIRECT_URI: {{ .Values.configuration.oidc.redirectURI | quote }}
OIDC_SCOPES: {{ .Values.configuration.oidc.scopes | quote }}
{{- end }}
DX_INTEGRATION_ENABLED: {{ .Values.configuration.integration.dx | quote }}
{{- if eq (.Values.configuration.authStrategy | lower ) "dx" }}
DX_USER_VALIDATION_ENDPOINT: {{ .Values.configuration.dx.userValidationEndpoint | quote }}
DX_SESSION_COOKIE_NAME: {{ .Values.configuration.dx.sessionCookieName | quote }}
DX_CURRENT_USER_ACCESS_ENDPOINT: {{ .Values.configuration.dx.currentUserAccessEndpoint | quote }}
DX_USER_ACCESS_PRIVILEDGED_ROLES_STRING: {{ .Values.configuration.dx.userAccessPrivilegedRoles | quote }}
DX_USER_ACCESS_CACHE_TTL: {{ int .Values.configuration.dx.cacheTTL | quote }}
DX_USER_ACCESS_CACHE_MAX_ENTRIES: {{ int .Values.configuration.dx.cacheMaxEntries | quote }}
DX_PORTLET_PAGE_CONTEXT: {{ .Values.configuration.dx.portletPageContextRoot | quote }}
{{- end }}
{{- if .Values.ldap.enabled }}
LDAP_CONFIG_URL: {{ .Values.ldap.host | quote }}
LDAP_CONFIG_BIND_DN: {{ .Values.ldap.bindDn | quote }}
LDAP_CONFIG_SEARCH_BASE: {{ .Values.ldap.searchBase | quote }}
LDAP_CONFIG_SEARCH_FILTER_ALL: {{ .Values.ldap.searchFilterAllUsers | quote }}
LDAP_CONFIG_SEARCH_FILTER_UID: {{ .Values.ldap.searchFilterUser | quote }}
LDAP_CONFIG_SEARCH_ATTRIBUTES_STRING: {{ include "hcl-people-service.ldapSearchAttributes" . | quote }}
LDAP_CONFIG_SEARCH_SCOPE: {{ .Values.ldap.searchScope | quote }}
LDAP_CONFIG_ATTRIBUTE_USER_IMAGE: {{ .Values.ldap.userImageAttribute | quote }}
LDAP_CONFIG_ATTRIBUTE_MAPPING_STRING: {{ include "hcl-people-service.ldapAttributeMapping" . | quote }}
{{- end }}
{{- if .Values.userSynchronization.enabled }}
USER_AGGREGATION_STRATEGY: {{ .Values.userSynchronization.strategy | quote }}
USER_SYNCHRONIZATION_CRON_SCHEDULE: {{ .Values.userSynchronization.cronSchedule | quote }}
USER_SYNCHRONIZATION_PREVENT_CONCURRENT_EXEC: {{ .Values.userSynchronization.preventConcurrentExecution | quote }}
{{- end }}
{{- if .Values.configuration.search.middleware.enabled }}
  {{- if .Values.configuration.integration.dx }}
SEARCH_MIDDLEWARE_CONTENT_SOURCE_ID: {{ .Values.configuration.search.contentSourceId | quote }}
  {{- else if not .Values.configuration.integration.dx }}
SEARCH_MIDDLEWARE_CONTENT_SOURCE_ID: {{ .Values.configuration.search.contentSourceId | quote }}
SEARCH_MIDDLEWARE_ENABLED: {{ .Values.configuration.search.middleware.enabled | quote }}
SEARCH_MIDDLEWARE_EXTERNAL_PORT: {{ .Values.configuration.search.middleware.port | quote }}
SEARCH_MIDDLEWARE_EXTERNAL_SSL_ENABLED: {{ .Values.configuration.search.middleware.ssl | quote }}
SEARCH_MIDDLEWARE_HOST: {{ .Values.configuration.search.middleware.host | quote }}
SEARCH_MIDDLEWARE_SSL_ENABLED: "false"
  {{- end }}
{{- end }}
{{- end -}}
