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
  CONFIG MAP KEYS AND VALUES MUST BE ENCLOSED IN DOUBLE QUOTES
  CONFIG MAP KEYS MUST BE SORTED ALPHABETICALLY
  ENTRIES MUST BE TRIMMED MANUALLY + 1 WHITESPACE AFTER COLON
*/}}

{{- define "hcl-dx-deployment.coreConfig" -}}
"core.config.ai_enabled": "{{ .Values.configuration.core.contentAI.enabled }}"
"core.config.authoring": "{{ .Values.configuration.core.tuning.authoring }}"
"core.config.cc_enabled": "{{ include "hcl-dx-deployment.contentComposerEnabled" . }}"
"core.config.cc_url": "/dx/ui/content/static"
"core.config.config_wizard": "{{ .Values.configuration.core.tuning.configWizard }}"
"core.config.configure_tika": "{{ .Values.configuration.core.configureTika }}"
"core.config.content_ai_provider": "{{ .Values.configuration.core.contentAI.provider }}"
"core.config.context_root": "{{ .Values.networking.core.contextRoot }}"
"core.config.custom_ai_classname": "{{ .Values.configuration.core.contentAI.className }}"
"core.config.dam_enabled": "{{ include "hcl-dx-deployment.digitalAssetManagementEnabled" . }}"
"core.config.dam_url": "/dx/ui/dam/static"
"core.config.deployment_type": "helm"
"core.config.disable_stellent_dcs": "{{ .Values.configuration.core.disableStellentDCS }}"
"core.config.dxpicker_enabled": "{{ include "hcl-dx-deployment.dxPickerEnabled" . }}"
"core.config.dxpicker_url": "{{ include "hcl-dx-deployment.dxPickerUrl" . }}"
"core.config.enable_blueprint_assets": "{{ .Values.incubator.configuration.blueprint.enableAssets }}"
"core.config.enable_nexHaven": "{{ .Values.incubator.configuration.blueprint.enableNexHaven }}"
"core.config.home_path": "{{ .Values.networking.core.home }}"
"core.config.invalidation_domain": "{{.Values.configuration.core.invalidationDomain }}"
{{- if eq (include "hcl-dx-deployment.iqEnabled" .) "true" }}
"core.config.iq_enabled": "{{ include "hcl-dx-deployment.iqEnabled" . }}"
"core.config.iq_uri": "{{ include "hcl-dx-deployment.iqUri" . }}"
{{- end }}
"core.config.ldap_attribute_mapping_ldap": "{{ join "," .Values.configuration.core.ldap.attributeMappingLdap }}"
"core.config.ldap_attribute_mapping_portal": "{{ join "," .Values.configuration.core.ldap.attributeMappingPortal }}"
"core.config.ldap_attribute_non_supported": "{{ join "," .Values.configuration.core.ldap.attributeNonSupported }}"
"core.config.ldap_enabled": "{{ include "hcl-dx-deployment.ldapConfigurationEnabled" . }}"
"core.config.ldap_host": "{{ include "hcl-dx-deployment.ldapConfigurationHost" . }}"
"core.config.ldap_id": "{{ .Values.configuration.core.ldap.id }}"
"core.config.ldap_port": "{{ include "hcl-dx-deployment.ldapConfigurationPort" . }}"
"core.config.ldap_server_type": "{{ .Values.configuration.core.ldap.serverType }}"
"core.config.ldap_suffix": "{{ include "hcl-dx-deployment.ldapConfigurationSuffix" . }}"
"core.config.metrics_enabled": "{{ .Values.metrics.core.scrape }}"
{{- if eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true" }}
"core.config.people_service_context_root_api": "{{ .Values.peopleservice.networking.contextRoot.api }}"
"core.config.people_service_context_root_portlet": "{{ .Values.peopleservice.configuration.dx.portletPageContextRoot }}"
"core.config.people_service_context_root_ui": "{{ .Values.peopleservice.networking.contextRoot.ui }}"
{{- end }}
"core.config.people_service_enabled": "{{ include "hcl-dx-deployment.peopleServiceEnabled" . }}"
{{- if eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true" }}
"core.config.people_service_webresources_uri": "{{ include "hcl-dx-deployment.peopleServiceWebResourcesUri" . }}"
{{- end }}
"core.config.personalized_path": "{{ .Values.networking.core.personalizedHome }}"
"core.config.remote_search_auto_config_core_wait_time": "{{ .Values.configuration.remoteSearch.coreWaitTime }}"
"core.config.remote_search_auto_config_enabled": "{{ include "hcl-dx-deployment.configureRemoteSearch" . }}"
"core.config.remote_search_auto_config_rs_wait_time": "{{ .Values.configuration.remoteSearch.remoteSearchWaitTime }}"
{{- if eq (include "hcl-dx-deployment.searchUiV2Enabled" .) "true" }}
"core.config.search_input_redirect_version": "{{ include "hcl-dx-deployment.searchInputRedirectVersion" . }}"
{{- end }}
"core.config.search_middleware_enabled": "{{ include "hcl-dx-deployment.searchMiddlewareEnabled" . }}"
{{- if and (eq (include "hcl-dx-deployment.searchMiddlewareEnabled" .) "true") (eq (include "hcl-dx-deployment.peopleServiceEnabled" .) "true") }}
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
{{- end -}}