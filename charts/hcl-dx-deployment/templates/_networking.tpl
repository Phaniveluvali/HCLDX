{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021, 2024. All Rights Reserved. *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
  This file compiles the conditional statements that decide
  how an application is configured for internal and external communication.
*/}}

{{/*
  External Core Hostname reference value.
*/}}
{{- define "hcl-dx-deployment.externalCoreHost" -}}
  {{- if .Values.networking.core.host -}}
    {{- /*
      If there is a hostname defined in the deployment value file, it will be configured explicitly.
    */}}
    {{- printf .Values.networking.core.host -}}
  {{- else if and (lookup "v1" "Service" .Release.Namespace (printf "%s-haproxy" .Release.Name)) (eq (include "hcl-dx-deployment.haproxyEnabled" .) "true") -}}
    {{- /*
      Otherwise we use either hostname or ip from the haproxy LoadBalancer if HAProxy Service is of type LoadBalancer
    */}}
    {{- if and (eq .Values.networking.haproxy.serviceType "LoadBalancer") (lookup "v1" "Service" .Release.Namespace (printf "%s-haproxy" .Release.Name)).status.loadBalancer -}}
      {{- $hostname := (index (lookup "v1" "Service" .Release.Namespace (printf "%s-haproxy" .Release.Name)).status.loadBalancer.ingress 0).hostname -}}
      {{- if $hostname -}}
        {{- printf (toString $hostname) -}}
      {{- else -}}
        {{- printf (toString (index (lookup "v1" "Service" .Release.Namespace (printf "%s-haproxy" .Release.Name)).status.loadBalancer.ingress 0).ip) -}}
      {{- end -}}
    {{- else -}}
      {{- printf "" -}}
    {{- end -}}

  {{- else -}}
    {{- /*
      For all other cases we fallback to an empty host value. This is mainly used for the initial startup.
      An helm upgrade afterwards will then retrieve the actual externalCoreHost using the above logic.
    */}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
  Internal Core Hostname reference value
  If Core is not deployed, use external Core.
  If internal calls use HAProxy, we use the HAProxy internal service name
*/}}
{{- define "hcl-dx-deployment.internalCoreHost" -}}
  {{- if .Values.networking.addon.internalCallsUseHaproxy -}}
    {{- printf .Release.Name -}}{{- printf "-haproxy-internal" -}}
  {{- else if eq (include "hcl-dx-deployment.coreEnabled" .) "true" -}} 
    {{- printf .Release.Name -}}{{- printf "-core" -}}
  {{- else if eq (include "hcl-dx-deployment.webEngineEnabled" .) "true" -}}
    {{- printf .Release.Name -}}{{- printf "-web-engine" -}}
  {{- else -}}
    {{- printf (include "hcl-dx-deployment.externalCoreHost" .) -}}
  {{- end -}}
{{- end -}}

{{/*
  External Addon application hostname reference value
  If none defined, we use the Core hostname
*/}}
{{- define "hcl-dx-deployment.externalAddonHost" -}}
  {{- if (.Values.networking.addon.host) -}}
    {{- printf .Values.networking.addon.host -}}
  {{- end -}}
{{- end -}}

{{/*
  DAM staging application hostname reference value
  If none defined, we use the Core hostname
*/}}
{{- define "hcl-dx-deployment.externalDamStagingHost" -}}
  {{- if (.Values.networking.addon.digitalAssetManagement.staging.host) -}}
    {{- printf .Values.networking.addon.digitalAssetManagement.staging.host -}}
  {{- else -}}
    {{- printf (include "hcl-dx-deployment.externalCoreHost" .) -}}
  {{- end -}}
{{- end -}}

{{/*
  External Core port reference value
  If not defined, we return 443
*/}}
{{- define "hcl-dx-deployment.externalCorePort" -}}
  {{- if (.Values.networking.core.port) -}}
    {{- printf (toString .Values.networking.core.port) -}}
  {{- else -}}
    {{- printf "443" -}}
  {{- end -}}
{{- end -}}

{{/*
  Internal Core port reference value
  If core is deployed in Kubernetes, we return hcl-dx-deployment.ports.core.dxHomeSecure
  Else, we return the external Core port
  If internal calls use HAProxy, we do use the dxHomeSecure port since we are using the same port in the internal HAProxy service. 
  This is to prevent an undefined virtual host error in Core for different ports
*/}}
{{- define "hcl-dx-deployment.internalCorePort" -}}
  {{- if eq (include "hcl-dx-deployment.coreEnabled" .) "true" -}}
    {{- if .Values.networking.addon.internalCallsUseHaproxy -}}
      {{- printf (include "hcl-dx-deployment.ports.core.dxHomeSecure" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.ports.core.dxHomeSecure" .) -}}
    {{- end -}}
  {{- else if eq (include "hcl-dx-deployment.webEngineEnabled" .) "true" -}}
    {{- if .Values.networking.addon.internalCallsUseHaproxy -}}
      {{- printf (include "hcl-dx-deployment.ports.webEngine.dxHomeSecure" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.ports.webEngine.dxHomeSecure" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf (include "hcl-dx-deployment.externalCorePort" .) -}}
  {{- end -}}
{{- end -}}

{{/*
  External Addon port reference value
  If not defined, we use the one from core
*/}}
{{- define "hcl-dx-deployment.externalAddonPort" -}}
  {{- if .Values.networking.addon.port -}}
    {{- printf (toString .Values.networking.addon.port) -}}
  {{- else -}}
    {{- if .Values.networking.core.port -}}
      {{- printf (toString .Values.networking.core.port) -}}
    {{- else -}}
      {{- printf "443" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  External DAM staging port reference value
  If not defined, we use the one from core
*/}}
{{- define "hcl-dx-deployment.externalDamStagingPort" -}}
  {{- if .Values.networking.addon.digitalAssetManagement.staging.port -}}
    {{- printf (toString .Values.networking.addon.digitalAssetManagement.staging.port) -}}
  {{- else -}}
    {{- if .Values.networking.core.port -}}
      {{- printf (toString .Values.networking.core.port) -}}
    {{- else -}}
      {{- printf "443" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  External Core SSL setting
  If not defined, we return true
*/}}
{{- define "hcl-dx-deployment.externalCoreSsl" -}}
  {{- if (toString (.Values.networking.core.ssl)) -}}
      {{- printf (toString (.Values.networking.core.ssl)) -}}
  {{- else -}}
      {{- printf "true" -}}
  {{- end -}}
{{- end -}}

{{/*
  Internal Core SSL setting
  If core is deployed in Kubernetes, we return true
  Else, we return the external SSL setting
*/}}
{{- define "hcl-dx-deployment.internalCoreSsl" -}}
  {{- if eq (include "hcl-dx-deployment.coreEnabled" .) "true" -}}
    {{- printf "true" -}}
  {{- else if eq (include "hcl-dx-deployment.webEngineEnabled" .) "true" -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf (include "hcl-dx-deployment.externalCoreSsl" .) -}}
  {{- end -}}
{{- end -}}

{{/*
  External Addon SSL setting
  If not defined, we return the core value
*/}}
{{- define "hcl-dx-deployment.externalAddonSsl" -}}
  {{- if (toString (.Values.networking.addon.ssl)) -}}
      {{- printf (toString ( .Values.networking.addon.ssl )) -}}
  {{- else -}}
    {{- if (toString (.Values.networking.core.ssl)) -}}
        {{- printf (toString ( .Values.networking.core.ssl )) -}}
    {{- else -}}
        {{- printf "true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  External DAM staging SSL setting
  If not defined, we return the core value
*/}}
{{- define "hcl-dx-deployment.externalDamStagingSsl" -}}
  {{- if (toString (.Values.networking.addon.digitalAssetManagement.staging.ssl)) -}}
      {{- printf (toString ( .Values.networking.addon.digitalAssetManagement.staging.ssl )) -}}
  {{- else -}}
    {{- if (toString (.Values.networking.core.ssl)) -}}
        {{- printf (toString ( .Values.networking.core.ssl )) -}}
    {{- else -}}
        {{- printf "true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* 
  Hybrid detection
  Hybrid is the case if Core is not deployed, and core host and addon host differ
*/}}
{{- define "hcl-dx-deployment.isHybridDeployment" -}}
  {{- if or (eq (include "hcl-dx-deployment.coreEnabled" .) "true") (eq (include "hcl-dx-deployment.webEngineEnabled" .) "true") -}}
    {{- printf "false" -}}
  {{- else -}}
    {{- if ne (include "hcl-dx-deployment.externalCoreHost" .) .Values.networking.addon.host -}}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Hybrid CORS Origin template
  Automatically creates the correct CORS origin for hybrid deployments
  If a custom port is configured, that one will be added as well
*/}}
{{- define "hcl-dx-deployment.hybridCorsOrigin" -}}
  {{- if .Values.networking.core.port -}}
    {{- printf "https://%s:%s,http://%s:%s" (include "hcl-dx-deployment.externalCoreHost" .) (toString .Values.networking.core.port) (include "hcl-dx-deployment.externalCoreHost" .) (toString .Values.networking.core.port) -}}
  {{- else -}}
    {{- printf "https://%s,http://%s" (include "hcl-dx-deployment.externalCoreHost" .) (include "hcl-dx-deployment.externalCoreHost" .) -}}
  {{- end -}}
{{- end -}}

{{/*
  Content Composer CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.contentComposerCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.contentComposer.corsOrigin -}}
      {{- printf "%s,%s" ( join "," .Values.networking.addon.contentComposer.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.contentComposer.corsOrigin ) -}}
  {{- end -}}
{{- end -}}

{{/*
  Digital Asset Management CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.digitalAssetManagementCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.digitalAssetManagement.corsOrigin -}}
      {{- printf "%s,%s" ( join "," .Values.networking.addon.digitalAssetManagement.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.digitalAssetManagement.corsOrigin ) -}}
  {{- end -}}
{{- end -}}

{{/*
  Image Processor CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.imageProcessorCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.imageProcessor.corsOrigin -}}
      {{- printf "%s,%s" ( join "," .Values.networking.addon.imageProcessor.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.imageProcessor.corsOrigin ) -}}
  {{- end -}}
{{- end -}}

{{/*
  DAM Plugin Google Vision CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.damPluginGoogleVisionCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.damPluginGoogleVision.corsOrigin -}}
      {{- printf "%s,%s" ( join "," .Values.networking.addon.damPluginGoogleVision.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.damPluginGoogleVision.corsOrigin ) -}}
  {{- end -}}
{{- end -}}

{{/*
  Ring API CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.ringApiCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.ringApi.corsOrigin -}}
      {{- printf "%s, %s" ( join "," .Values.networking.addon.ringApi.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.ringApi.corsOrigin ) -}}
  {{- end -}}
{{- end -}}

{{/*
  Core probe path - calculate depending upon context root etc.
*/}}
{{- define "hcl-dx-deployment.coreProbePath" -}}
  {{- if .Values.networking.core.contextRoot -}}
    {{- if .Values.networking.core.home -}}
      {{- printf "/%s/%s" .Values.networking.core.contextRoot .Values.networking.core.home -}}
    {{- else -}}
      {{- printf "/%s" .Values.networking.core.contextRoot -}}
    {{- end -}}
  {{- else -}}
    {{- if .Values.networking.core.home -}}
      {{- printf "/%s" .Values.networking.core.home -}}
    {{- else -}}
      {{- printf "/" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Web Engineprobe path - calculate depending upon context root etc.
*/}}
{{- define "hcl-dx-deployment.webEngineProbePath" -}}
  {{- if .Values.networking.webEngine.contextRoot -}}
    {{- if .Values.networking.webEngine.home -}}
      {{- printf "/%s/%s" .Values.networking.webEngine.contextRoot .Values.networking.webEngine.home -}}
    {{- else -}}
      {{- printf "/%s" .Values.networking.webEngine.contextRoot -}}
    {{- end -}}
  {{- else -}}
    {{- if .Values.networking.webEngine.home -}}
      {{- printf "/%s" .Values.networking.webEngine.home -}}
    {{- else -}}
      {{- printf "/" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Define a function to set context root for core or webEngine
*/}}
{{- define "hcl-dx-deployment.contextRoot" -}}
  {{- if eq (include "hcl-dx-deployment.webEngineEnabled" .) "true" }}
    {{- printf .Values.networking.webEngine.contextRoot -}}
  {{- else -}}
    {{- printf .Values.networking.core.contextRoot -}}
  {{- end -}}
{{- end -}}

{{/*
  HAProxy Service type logic 
*/}}
{{- define "hcl-dx-deployment.haproxyServiceType" -}}
  {{/* 
    If HAProxy run , ClusterIP is required. Otherwise we decide depending on the serviceType value
  */}}
  {{- if eq .Values.networking.haproxy.serviceType "ClusterIP" }}
    {{- printf "ClusterIP" -}}
  {{- else if (eq .Values.networking.haproxy.serviceType "NodePort") -}}
    {{- printf "NodePort" -}}
  {{- else -}}
    {{- printf "LoadBalancer" -}}
  {{- end -}}
{{- end -}}

{{/*
  HAProxy port logic 
*/}}
{{- define "hcl-dx-deployment.haproxyServicePort" -}}
  {{/* 
    Set the port exposed by the HAProxy Service. If this is not set in the values, port 80 will be used if SSL offloading is disabled. If it is enabled port 443 is used
  */}}
  {{- if .Values.networking.haproxy.servicePort -}}
    {{- printf (toString .Values.networking.haproxy.servicePort) -}}
  {{- else if (and .Values.networking.haproxy.ssl (ne (include "hcl-dx-deployment.isSofyDeployment" .) "true")) -}}
    {{- printf "443" -}}
  {{- else -}}
    {{- printf "80" -}}
  {{- end -}}
{{- end -}}

{{/*
  friendlyUrlContextRoot logic
*/}}
{{- define "hcl-dx-deployment.friendlyUrlContextRoot" -}}
  {{/* Trim spaces and leading/trailing slashes to normalize input */}}
  {{- $trimmedPath := (trimAll "/" (trim .Values.configuration.digitalAssetManagement.friendlyUrlContextRoot)) -}}
  {{/* If no path is set we return an empty string */}}
  {{- if not $trimmedPath -}}
    {{- printf "" -}}
  {{/* If the first path element is dx we disallow as it is reserved for dx apps */}}
  {{- else if (or (regexMatch "^dx/" $trimmedPath) (eq "dx" $trimmedPath)) -}}
    {{- fail "The /dx path that was set as \"friendlyUrlContextRoot\" is reserved for DX applications. Please choose a different path to prevent conflicts." -}}
  {{- else -}}
    {{- printf $trimmedPath -}}
  {{- end -}}
{{- end -}}

{{/*
  DAM kaltura plugin CORS Origin
  Will automatically adopt necessary settings if a hybrid scenario is deployed.
*/}}
{{- define "hcl-dx-deployment.damPluginKalturaCorsOrigin" -}}
  {{- if eq (include "hcl-dx-deployment.isHybridDeployment" .) "true" -}}
    {{- if .Values.networking.addon.damPluginKaltura.corsOrigin -}}
      {{- printf "%s,%s" ( join "," .Values.networking.addon.damPluginKaltura.corsOrigin) (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- else -}}
      {{- printf (include "hcl-dx-deployment.hybridCorsOrigin" .) -}}
    {{- end -}}
  {{- else -}}
    {{- printf ( join "," .Values.networking.addon.damPluginKaltura.corsOrigin) -}}
  {{- end -}}
{{- end -}}

{{/*
  HAProxy Affinity Cookie Domain affinityCookieDomain
  If affinityCookieDomain is not defined, fallback to not setting the domain. 
  HAProxy will use the originating domain in that case.
*/}}
{{- define "hcl-dx-deployment.affinityCookieDomain" -}}
  {{- if .Values.networking.haproxy.affinityCookieDomain -}}
    {{- range .Values.networking.haproxy.affinityCookieDomain -}}
      {{- printf "domain %s " . -}}
    {{- end -}}
  {{- else -}}
    {{- printf " " -}}
  {{- end -}}
{{- end -}}