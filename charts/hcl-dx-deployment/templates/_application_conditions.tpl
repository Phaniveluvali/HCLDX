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
This file compiles the conditional statements that decide, whether
an application will be deployed or not.
*/}}

{{/* Starting with HCL DX CF201 it is mandatory to have the new DAM database. The helm upgrade will fail if the migration has not been processed before. */}}
{{- define "hcl-dx-deployment.isPersistenceNodeDeployed" -}}
  {{/* Check if new database is deployed */}}
  {{- if (lookup "apps/v1" "StatefulSet" .Release.Namespace (printf "%s-persistence-node" .Release.Name)) }}
    {{- printf "true" -}}
  {{/* If new database is not deployed, we check if no database is deployed at all. This is also a valid case to allow fresh activations of DAM */}}
  {{- else if and (not (lookup "apps/v1" "StatefulSet" .Release.Namespace (printf "%s-persistence-node" .Release.Name))) (not (lookup "apps/v1" "StatefulSet" .Release.Namespace (printf "%s-persistence-rw" .Release.Name))) (not (lookup "apps/v1" "StatefulSet" .Release.Namespace (printf "%s-persistence-ro" .Release.Name))) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "hcl-dx-deployment.persistenceStatusCheck" -}}
  {{- if and (.Release.IsUpgrade ) (eq (include "hcl-dx-deployment.isPersistenceNodeDeployed" .) "false") -}}
    {{- required "Starting with HCL DX CF201 it is mandatory to have the new DAM database. The helm upgrade will fail if the migration has not been processed before. For DAM database migration instructions please refer to https://help.hcltechsw.com/digital-experience/9.5/containerization/helm_dam_migration_newDB.html" .Values.configuration.DigitalAssetManager }}
  {{- end -}}
{{- end -}}

{{/* wasUser and wpsUser condition */}}
{{/* If wasAdmin and wpsAdmin are set to the same user, the password needs to be the same as well */}}
{{- define "hcl-dx-deployment.isPasswordValidCheck" -}}
  {{- if (and (eq (.Values.security.core.wasUser) (.Values.security.core.wpsUser)) (ne (.Values.security.core.wasPassword) (.Values.security.core.wpsPassword))) -}}
    {{- fail "If wasAdmin and wpsAdmin are set to the same user, the password needs to be the same as well" -}}
  {{- end -}}
{{- end -}}

{{/* Runtime Controller condition */}}
{{/* Will be deployed if directly enabled*/}}
{{- define "hcl-dx-deployment.runtimeControllerEnabled" -}}
  {{- if (.Values.applications.runtimeController) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Validates the state of WebEngine and Core applications during an upgrade process to prevent invalid application state transitions. */}}
{{- define "hcl-dx-deployment.checkWebEngineAndCoreSwitchDuringUpgrade" -}}
  {{- $releaseName := .Release.Name -}}
  {{- $namespace := .Release.Namespace -}}
  {{- $coreConfigMap := (lookup "v1" "ConfigMap" $namespace (printf "%s-core" $releaseName)) -}}
  {{- $webEngineConfigMap := (lookup "v1" "ConfigMap" $namespace (printf "%s-web-engine" $releaseName)) -}}
  {{- $webEngineEnabled := .Values.applications.webEngine -}}
  {{- $coreEnabled := .Values.applications.core -}}

  {{- if and $coreConfigMap $webEngineEnabled -}}
    {{- fail "Upgrade failed: Switching from Core to WebEngine is not permitted during an upgrade. Ensure that WebEngine remains disabled if Core was enabled in the previous release. Uninstall the previous release to switch to WebEngine." -}}
  {{- end -}}
  {{- if and $webEngineConfigMap $coreEnabled -}}
    {{- fail "Upgrade failed: Switching from WebEngine to Core is not permitted during an upgrade. Ensure that Core remains disabled if WebEngine was enabled in the previous release. Uninstall the previous release to switch to Core." -}}
  {{- end -}}
{{- end -}}

{{/*
Check that only one of core or webEngine is enabled
*/}}
{{- define "hcl-dx-deployment.checkCoreOrWebEngineEnabled" -}}
  {{- $coreEnabled := .Values.applications.core -}}
  {{- $webEngineEnabled := .Values.applications.webEngine -}}

  {{- if and $coreEnabled $webEngineEnabled -}}
    {{- fail "Both core and webEngine cannot be enabled at the same time." -}}
  {{- end -}}
{{- end -}}

{{/* Core condition */}}
{{/* Will be deployed if core is enabled and webEngine is not enabled */}}
{{- define "hcl-dx-deployment.coreEnabled" -}}
  {{- if .Values.applications.core -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* WebEngine condition */}}
{{/* Will be deployed if webEngine is enabled and core is not enabled */}}
{{- define "hcl-dx-deployment.webEngineEnabled" -}}
  {{- if .Values.applications.webEngine -}}
    {{- printf "true" -}}
    {{- if .Values.applications.remoteSearch -}}
      {{- $_ := set .Values.applications "remoteSearch" false -}}
    {{- end -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Digital Asset Management condition */}}
{{/*
  Will be deployed if directly enabled or 
  DX Picker is enabled
*/}}
{{- define "hcl-dx-deployment.digitalAssetManagementEnabled" -}}
  {{- if .Values.applications.webEngine -}}
    {{- if ((.Values.applications.digitalAssetManagement)) -}}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- else -}}
    {{- if (or (.Values.applications.digitalAssetManagement) (.Values.applications.dxPicker)) -}}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Content Composer condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.contentComposerEnabled" -}}
  {{- if (.Values.applications.contentComposer) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Image Processor condition */}}
{{/*
  Will be deployed if directly enabled or
  Digital Asset Management is enabled
*/}}
{{- define "hcl-dx-deployment.imageProcessorEnabled" -}}
  {{- if (.Values.applications.imageProcessor) -}}
    {{- printf "true" -}}
  {{- else if (eq (include "hcl-dx-deployment.digitalAssetManagementEnabled" .) "true") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DAM Plugin Google Vision condition */}}
{{/*
  Will be deployed if directly enabled
*/}}
{{- define "hcl-dx-deployment.damPluginGoogleVisionEnabled" -}}
  {{- if (.Values.applications.damPluginGoogleVision) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Persistence condition */}}
{{/*
  Will be deployed if directly enabled or 
  Digital Asset Management is enabled
  and if persistence.host is empty
*/}}
{{- define "hcl-dx-deployment.persistenceEnabled" -}}
  {{- if (.Values.applications.persistence) -}}
    {{- printf "true" -}}
  {{- else if and (eq (include "hcl-dx-deployment.digitalAssetManagementEnabled" .) "true") (eq .Values.configuration.persistence.host "") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}} 
{{- end -}}

{{/* Ring API condition */}}
{{/* 
  Will be deployed if directly enabled or 
  Digital Asset Managent or Content Composer are enabled.
*/}}
{{- define "hcl-dx-deployment.ringApiEnabled" -}}
  {{- if (.Values.applications.ringApi) -}}
    {{- printf "true" -}}
  {{- else if (eq (include "hcl-dx-deployment.digitalAssetManagementEnabled" .) "true") -}}
    {{- printf "true" -}}
  {{- else if (.Values.applications.contentComposer) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* OpenLDAP condition */}}
{{/* Will be deployed if directly enabled or Core ldap is set to "dx" */}}
{{- define "hcl-dx-deployment.openLdapEnabled" -}}
  {{- if (.Values.applications.openLdap) -}}
    {{- printf "true" -}}
  {{- else if or (eq .Values.configuration.core.ldap.type "dx") (eq .Values.configuration.webEngine.ldap.type "dx")  -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Remote Search condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.remoteSearchEnabled" -}}
  {{- if (.Values.applications.remoteSearch) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* HAProxy condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.haproxyEnabled" -}}
  {{- if (.Values.applications.haproxy) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DX License Manager condition */}}
{{/* Starting with HCL DX CF206 if you use cloud native licensing it is mandatory to enable license manager application for entitlement checking. */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.licenseManagerEnabled" -}}
  {{- if (.Values.applications.licenseManager) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DAM kaltura plugin condition */}}
{{/*
  Will be deployed if directly enabled
*/}}
{{- define "hcl-dx-deployment.damPluginKalturaEnabled" -}}
  {{- if (.Values.applications.damPluginKaltura) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DX Picker condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.dxPickerEnabled" -}}
  {{- if (.Values.applications.dxPicker) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DX Picker url condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.dxPickerUrl" -}}
  {{- if (.Values.incubator.configuration.dxPicker.renderPickerSearch) -}}
    {{- printf "/dx/ui/search/picker" -}}
  {{- else -}}
    {{- printf "/dx/ui/picker/static" -}}
  {{- end -}}
{{- end -}}

{{/* People Service condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.peopleServiceEnabled" -}}
  {{- if (.Values.peopleservice.enabled) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}


{{/* HSTS Headers preload validation to include, includeSubDomains and maxAge */}}
{{/* If preload is enabled, the max-age directive must be at least 31536000 (1 year), and the includeSubDomains directive must be present  */}}
{{- define "hcl-dx-deployment.isPreloadValidCheck" -}}
  {{- if (and (.Values.networking.haproxy.strictTransportSecurity.enabled) (.Values.networking.haproxy.strictTransportSecurity.preload) (or (not (.Values.networking.haproxy.strictTransportSecurity.includeSubDomains)) (lt (int .Values.networking.haproxy.strictTransportSecurity.maxAge) 31536000))) -}}
    {{- fail "When using networking.haproxy.strictTransportSecurity.preload, the networking.haproxy.strictTransportSecurity.maxAge directive must be at least 31536000 (1 year), and the networking.haproxy.strictTransportSecurity.includeSubDomains directive must be present" -}}
  {{- end -}}
{{- end -}}

{{/* Search Middleware condition */}}
{{/* Will enable indexing */}}
{{- define "hcl-dx-deployment.searchMiddlewareEnabled" -}}
  {{- if (.Values.configuration.searchMiddleware.enabled) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* DAM Indexing condition */}}
{{/* Will enable DAM indexing */}}
{{- define "hcl-dx-deployment.damIndexingEnabled" -}}
  {{- if and (.Values.configuration.searchMiddleware.damIndexing) (.Values.configuration.searchMiddleware.enabled) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* Search condition */}}
{{/* Will be deployed if directly enabled */}}
{{- define "hcl-dx-deployment.searchUiV2Enabled" -}}
  {{- if (.Values.applications.core) -}}
    {{- if and (.Values.configuration.core.search.uiV2Enabled) (.Values.configuration.searchMiddleware.enabled) -}}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- else if (.Values.applications.webEngine) -}}
    {{- if (.Values.configuration.searchMiddleware.enabled) -}}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Search Middleware condition */}}
{{- define "hcl-dx-deployment.searchMiddlewareUiUri" -}}
  {{- if and (.Values.networking.searchMiddlewareService) (.Values.configuration.searchMiddleware.enabled) -}}
      {{- printf "http://" -}}{{- printf (.Values.networking.searchMiddlewareService) -}}{{- printf ":3000/dx/ui/search" -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{- define "hcl-dx-deployment.searchInputRedirectVersion" -}}
  {{- if (.Values.applications.core) -}}
    {{- if and (.Values.configuration.core.search.uiV2Enabled) (.Values.configuration.core.search.inputRedirectVersion) (.Values.configuration.searchMiddleware.enabled) -}}
      {{- if (eq (.Values.configuration.core.search.inputRedirectVersion) "v2") -}}
        {{- printf "2" -}}
      {{- else -}}
        {{- printf "1" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "1" -}}
    {{- end -}}
  {{- else if (.Values.applications.webEngine) -}}
    {{- if (.Values.configuration.searchMiddleware.enabled) -}}
      {{- printf "2" -}}
    {{- else -}}
      {{- printf "1" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "hcl-dx-deployment.searchWcmVersion" -}}
  {{- if (.Values.applications.core) -}}
    {{- if and (.Values.configuration.core.search.uiV2Enabled) (.Values.configuration.core.search.wcmVersion) (.Values.configuration.searchMiddleware.enabled) -}}
      {{- if (eq (.Values.configuration.core.search.wcmVersion) "v2") -}}
        {{- printf "2" -}}
      {{- else -}}
        {{- printf "1" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "1" -}}
    {{- end -}}
  {{- else if (.Values.applications.webEngine) -}}
    {{- if (.Values.configuration.searchMiddleware.enabled) -}}
      {{- printf "2" -}}
    {{- else -}}
      {{- printf "1" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Check that when useExternalDatabase is false, webEngine replicas should remain at 1 */}}
{{- define "hcl-dx-deployment.checkWebEngineReplicasWithExternalDB" -}}
  {{- if (.Values.applications.webEngine) -}}
    {{- $useExternalDB := .Values.configuration.webEngine.useExternalDatabase -}}
    {{- $webEngineReplicas := .Values.scaling.replicas.webEngine -}}
    {{- if and (not $useExternalDB) (gt (int $webEngineReplicas) 1) -}}
      {{- fail "When useExternalDatabase is false, webEngine uses Derby, which doesn’t support pod scaling. Set webEngine replicas to 1, or enable useExternalDatabase to use a scalable external database." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* IQ UI conditions */}}
{{- define "hcl-dx-deployment.iqUri" -}}
  {{- if (.Values.incubator.networking.dxIqService) -}}
      {{- printf "http://" -}}{{- printf (.Values.incubator.networking.dxIqService) -}}{{- printf ":3000/dx/ui/iq" -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{- define "hcl-dx-deployment.iqEnabled" -}}
  {{- if (.Values.incubator.networking.dxIqService) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}
