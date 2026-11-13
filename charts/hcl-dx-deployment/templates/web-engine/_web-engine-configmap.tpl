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
  CONFIG MAP KEYS AND VALUES MUST BE ENCLOSED IN DOUBLE QUOTES
  CONFIG MAP KEYS MUST BE SORTED ALPHABETICALLY
  ENTRIES MUST BE TRIMMED MANUALLY + 1 WHITESPACE AFTER COLON
*/}}

{{- define "hcl-dx-deployment.webEngineConfig" -}}
"core.config.ai_enabled": "{{ .Values.configuration.webEngine.contentAI.enabled }}"
"core.config.authoring": "{{ .Values.configuration.webEngine.tuning.authoring }}"
"core.config.cc_enabled": "{{ include "hcl-dx-deployment.contentComposerEnabled" . }}"
"core.config.cc_url": "/dx/ui/content/static"
"core.config.content_ai_provider": "{{ .Values.configuration.webEngine.contentAI.provider }}"
"core.config.context_root": "{{ .Values.networking.webEngine.contextRoot }}"
"core.config.custom_ai_classname": "{{ .Values.configuration.webEngine.contentAI.className }}"
"core.config.dam_enabled": "{{ include "hcl-dx-deployment.digitalAssetManagementEnabled" . }}"
"core.config.dam_url": "/dx/ui/dam/static"
"core.config.deployment_type": "helm"
"core.config.drop_database_tables": "{{ .Values.configuration.webEngine.dropDatabaseTables }}"
"core.config.dxpicker_enabled": "{{ include "hcl-dx-deployment.dxPickerEnabled" . }}"
"core.config.dxpicker_url": "/dx/ui/picker/static"
"core.config.enable_blueprint_assets": "{{ .Values.incubator.configuration.blueprint.enableAssets }}"
"core.config.enable_nexHaven": "{{ .Values.incubator.configuration.blueprint.enableNexHaven }}"
"core.config.home_path": "{{ .Values.networking.webEngine.home }}"
"core.config.host_name": "{{ .Values.networking.webEngine.host }}"
{{- if eq (include "hcl-dx-deployment.iqEnabled" .) "true" }}
"core.config.iq_enabled": "{{ include "hcl-dx-deployment.iqEnabled" . }}"
"core.config.iq_uri": "{{ include "hcl-dx-deployment.iqUri" . }}"
{{- end }}
"core.config.ldap_attribute_mapping_ldap": "{{ join "," .Values.configuration.webEngine.ldap.attributeMappingLdap }}"
"core.config.ldap_attribute_mapping_portal": "{{ join "," .Values.configuration.webEngine.ldap.attributeMappingPortal }}"
"core.config.ldap_attribute_non_supported": "{{ join "," .Values.configuration.webEngine.ldap.attributeNonSupported }}"
"core.config.ldap_enabled": "{{ include "hcl-dx-deployment.ldapWebEngineConfigurationEnabled" . }}"
"core.config.ldap_host": "{{ include "hcl-dx-deployment.ldapWebEngineConfigurationHost" . }}"
"core.config.ldap_id": "{{ .Values.configuration.webEngine.ldap.id }}"
"core.config.ldap_port": "{{ include "hcl-dx-deployment.ldapWebEngineConfigurationPort" . }}"
"core.config.ldap_server_type": "{{ .Values.configuration.webEngine.ldap.serverType }}"
"core.config.ldap_suffix": "{{ include "hcl-dx-deployment.ldapWebEngineConfigurationSuffix" . }}"
"core.config.metrics_enabled": "{{ .Values.metrics.webEngine.scrape }}"
{{- if eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true" }}
"core.config.people_service_context_root_api": "{{ .Values.peopleservice.networking.contextRoot.api }}"
"core.config.people_service_context_root_portlet": "{{ .Values.peopleservice.configuration.dx.portletPageContextRoot }}"
"core.config.people_service_context_root_ui": "{{ .Values.peopleservice.networking.contextRoot.ui }}"
{{- end }}
"core.config.people_service_enabled": "{{ include "hcl-dx-deployment.peopleServiceEnabled" . }}"
{{- if eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true" }}
"core.config.people_service_webresources_uri": "{{ include "hcl-dx-deployment.peopleServiceWebResourcesUri" . }}"
{{- end }}
"core.config.personalized_path": "{{ .Values.networking.webEngine.personalizedHome }}"
{{- if eq (include "hcl-dx-deployment.searchUiV2Enabled" .) "true" }}
"core.config.search_input_redirect_version": "{{ include "hcl-dx-deployment.searchInputRedirectVersion" . }}"
{{- end }}
"core.config.search_middleware_enabled": "{{ include "hcl-dx-deployment.searchMiddlewareEnabled" . }}"
{{- if eq (include "hcl-dx-deployment.searchMiddlewareEnabled" .) "true" }}
"core.config.search_middleware_external_port": "{{ .Values.configuration.searchMiddleware.port }}"
"core.config.search_middleware_external_ssl_enabled": "{{ .Values.configuration.searchMiddleware.ssl }}"
"core.config.search_middleware_host": "{{ .Values.configuration.searchMiddleware.host }}"
"core.config.search_middleware_ssl_enabled": "false"
{{- end }}
{{- if eq (include "hcl-dx-deployment.searchUiV2Enabled" .) "true" }}
"core.config.search_middleware_ui_uri": "{{ include "hcl-dx-deployment.searchMiddlewareUiUri" . }}"
{{- end }}
"core.config.search_ui_v2_enabled": "{{ include "hcl-dx-deployment.searchUiV2Enabled" . }}"
{{- if eq (include "hcl-dx-deployment.searchUiV2Enabled" .) "true" }}
"core.config.search_wcm_version": "{{ include "hcl-dx-deployment.searchWcmVersion" . }}"
{{- end }}
"core.config.skip_blueprint_assets_update": "{{ .Values.incubator.configuration.blueprint.skipAssetsUpdate }}"
"core.config.skip_nexHaven_update": "{{ .Values.incubator.configuration.blueprint.skipNexHavenUpdate }}"
"core.config.use_external_database": "{{ .Values.configuration.webEngine.useExternalDatabase }}"
{{- end -}}
