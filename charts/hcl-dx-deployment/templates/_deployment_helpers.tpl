{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021, 2026. All Rights Reserved. *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
This file compiles helpers regarding the overall deployment
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "hcl-dx-deployment.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hcl-dx-deployment.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hcl-dx-deployment.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hcl-dx-deployment.labels" -}}
release: "{{ .Release.Name }}"
helm.sh/chart: {{ include "hcl-dx-deployment.chart" . }}
{{ include "hcl-dx-deployment.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hcl-dx-deployment.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hcl-dx-deployment.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
DAM persistence database name
*/}}
{{- define "hcl-dx-deployment.damDatabaseName" -}}
  {{- printf .Values.configuration.persistence.databaseName -}}
{{- end }}

{{/* 
  OpenShift detection
*/}}
{{- define "hcl-dx-deployment.isOpenShift" -}}
  {{- if .Capabilities.APIVersions.Has "project.openshift.io/v1" -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end }}

{{/*
Create image repository path
*/}}
{{- define "hcl-dx-deployment.imageRepository" -}}
  {{- if (include "hcl-dx-deployment.ambassadorID" .) }}
    {{- if eq .Values.global.hclImageRegistry "hclcr.io/sofy" -}}
      hclcr.io
    {{- else if eq .Values.global.hclImageRegistry "gcr.io/blackjack-209019" -}}
      gcr.io/blackjack-209019/services
    {{- else if eq .Values.global.hclPreviewImageRegistry "hclcr.io/sofy-hcl-users" -}}
      hclcr.io/sofy-hcl-users/services
    {{- else -}}
      {{- printf .Values.global.hclImageRegistry -}}
    {{- end -}}
  {{- else -}}
    {{- printf .Values.images.repository -}}
  {{- end -}}
{{- end -}}

{{/*
RW storage class name for core
*/}}
{{- define "hcl-dx-deployment.coreStorageClassName" -}}
  {{- if .Values.global.persistence.rwxStorageClassV3 -}}
    {{- printf .Values.global.persistence.rwxStorageClassV3 -}}
  {{- else -}}
    {{- printf .Values.volumes.core.profile.storageClassName -}}
  {{- end -}}
{{- end -}}

{{/*
RW storage class name for dam
*/}}
{{- define "hcl-dx-deployment.damStorageClassName" -}}
  {{- if .Values.global.persistence.rwxStorageClassV3 -}}
    {{- printf .Values.global.persistence.rwxStorageClassV3 -}}
  {{- else -}}
    {{- printf .Values.volumes.digitalAssetManagement.binaries.storageClassName -}}
  {{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "hcl-dx-deployment.imagePullSecret" -}}
imagePullSecrets:
  {{- if (.Values.global) }}
    {{- if (.Values.global.hclImagePullSecret) }}
  - name: {{ .Values.global.hclImagePullSecret }}
    {{- end }}
  {{- end }}
  {{- if (.Values.images) }}
    {{- if (.Values.images.imagePullSecrets) }}
  {{- toYaml (.Values.images.imagePullSecrets) | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Create ambassador id
*/}}
{{- define "hcl-dx-deployment.ambassadorID" -}}
    {{- if .Values.global.emissaryID }}
      {{- printf .Values.global.emissaryID -}}
    {{- else if .Values.global.ambassadorID -}}
      {{- printf .Values.global.ambassadorID -}}
    {{- end -}}
{{- end -}}

{{/*
Check is SoFy deployment
*/}}
{{- define "hcl-dx-deployment.isSofyDeployment" -}}
  {{- if .Values.global }}
    {{- if (include "hcl-dx-deployment.ambassadorID" .) }}
      {{- printf "true" -}}
    {{- else -}}
      {{- printf "false" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/*
Define reusable secret checksum for core
*/}}
{{- define "hcl-dx-deployment.coreCredentialsChecksum" -}}
  {{- /* Setting default wps and was username and passwords values */ -}}
  {{- $coreWasUser := .Values.security.core.wasUser }}
  {{- $coreWasPassword := .Values.security.core.wasPassword }}
  {{- $coreWpsUser := .Values.security.core.wpsUser }}
  {{- $coreWpsPassword := .Values.security.core.wpsPassword }}

  {{- /* Checking if validations are passed for wasUsername and wasPasswords. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomWasSecretUsed" .) "true") }}
    {{- $currentCustomWasSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.core.customWasSecret ) }}
    {{- $coreWasUser = (b64dec (get $currentCustomWasSecret.data "username")) }}
    {{- $coreWasPassword = (b64dec (get $currentCustomWasSecret.data "password")) }}
  {{- end -}}

  {{- /* Checking if validations are passed for wpsUsername and wpsPasswords. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomWpsSecretUsed" .) "true") }}
    {{- $currentCustomWpsSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.core.customWpsSecret ) }}
    {{- $coreWpsUser = (b64dec (get $currentCustomWpsSecret.data "username")) }}
    {{- $coreWpsPassword = (b64dec (get $currentCustomWpsSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for core  */ -}}
  {{- printf (printf "%s %s %s %s" ($coreWasUser | sha256sum) ($coreWasPassword | sha256sum) ($coreWpsUser | sha256sum) ($coreWpsPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for core
*/}}
{{- define "hcl-dx-deployment.configWizardCredentialsChecksum" -}}
  {{- /* Setting default Config Wizard username and password values */ -}}
  {{- $configWizardUser := .Values.security.core.configWizardUser }}
  {{- $configWizardPassword := .Values.security.core.configWizardPassword }}

  {{- /* Checking if validations are passed for configWizardUser and configWizardPassword. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomConfigWizardSecretUsed" .) "true") }}
    {{- $currentCustomConfigWizardSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.core.customConfigWizardSecret ) }}
    {{- $configWizardUser = (b64dec (get $currentCustomConfigWizardSecret.data "username")) }}
    {{- $configWizardPassword = (b64dec (get $currentCustomConfigWizardSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for core  */ -}}
  {{- printf (printf "%s %s" ($configWizardUser | sha256sum) ($configWizardPassword | sha256sum)) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for remote search
*/}}
{{- define "hcl-dx-deployment.remoteSearchCredentialsChecksum" -}}
  {{- /* Setting default was username and passwords values */ -}}
  {{- $rsWasUser := .Values.security.remoteSearch.wasUser }}
  {{- $rsWasPassword := .Values.security.remoteSearch.wasPassword }}

  {{- /* Checking if validations are passed for wasUsername and wasPasswords. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomRemoteSearchSecretUsed" .) "true") }}
    {{- $currentCustomWasSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.remoteSearch.customWasSecret ) }}
    {{- $rsWasUser = (b64dec (get $currentCustomWasSecret.data "username")) }}
    {{- $rsWasPassword = (b64dec (get $currentCustomWasSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for remote search  */ -}}
  {{- printf (printf "%s %s" ($rsWasUser | sha256sum) ($rsWasPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for Persistence Replication User
*/}}
{{- define "hcl-dx-deployment.replicationUserCredentialsChecksum" -}}
  {{- /* Setting default replication username and passwords values */ -}}
  {{- $replicationUser := .Values.security.digitalAssetManagement.replicationUser }}
  {{- $replicationPassword := .Values.security.digitalAssetManagement.replicationPassword }}

  {{- /* Checking if validations are passed for replicationUserName and replicationPassword. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomReplicationSecretUsed" .) "true") }}
    {{- $replicationCustomSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.digitalAssetManagement.customReplicationSecret ) }}
    {{- $replicationUser = (b64dec (get $replicationCustomSecret.data "username")) }}
    {{- $replicationPassword = (b64dec (get $replicationCustomSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for remote search  */ -}}
  {{- printf (printf "%s %s" ($replicationUser | sha256sum) ($replicationPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for DAM Crud user
*/}}
{{- define "hcl-dx-deployment.damCrudUserCredentialsChecksum" -}}
  {{- /* Setting default DB username and passwords values */ -}}
  {{- $damUser := .Values.security.digitalAssetManagement.damUser }}
  {{- $damPassword := .Values.security.digitalAssetManagement.damPassword }}

  {{- /* Checking if validations are passed for DB Username and Password. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomDamCrudSecretUsed" .) "true") }}
    {{- $dbCustomSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.digitalAssetManagement.customDamSecret ) }}
    {{- $damUser = (b64dec (get $dbCustomSecret.data "username")) }}
    {{- $damPassword = (b64dec (get $dbCustomSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for remote search  */ -}}
  {{- printf (printf "%s %s" ($damUser | sha256sum) ($damPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for Persistence DB User
*/}}
{{- define "hcl-dx-deployment.dbCredentialsChecksum" -}}
  {{- /* Setting default DB username and passwords values */ -}}
  {{- $dbUser := .Values.security.digitalAssetManagement.dbUser }}
  {{- $dbPassword := .Values.security.digitalAssetManagement.dbPassword }}

  {{- /* Checking if validations are passed for DB Username and Password. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomDBSecretUsed" .) "true") }}
    {{- $dbCustomSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.digitalAssetManagement.customDBSecret ) }}
    {{- $dbUser = (b64dec (get $dbCustomSecret.data "username")) }}
    {{- $dbPassword = (b64dec (get $dbCustomSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for remote search  */ -}}
  {{- printf (printf "%s %s" ($dbUser | sha256sum) ($dbPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for search-middleware
*/}}
{{- define "hcl-dx-deployment.searchCredentialsChecksum" -}}
  {{- /* Setting default push username and passwords values */ -}}
  {{- $pushAdminUser := .Values.configuration.searchMiddleware.pushAdminUser }}
  {{- $pushAdminPassword := .Values.configuration.searchMiddleware.pushAdminPassword }}

  {{- /* Checking if validations are passed for pushAdminUser and pushAdminPassword. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomPushAdminSecretUsed" .) "true") }}
    {{- $currentCustomPushAdminSecret := (lookup "v1" "Secret" .Release.Namespace .Values.configuration.searchMiddleware.customPushAdminSecret ) }}
    {{- $pushAdminUser = (b64dec (get $currentCustomPushAdminSecret.data "username")) }}
    {{- $pushAdminPassword = (b64dec (get $currentCustomPushAdminSecret.data "password")) }}
  {{- end -}}

  {{- /* Creating the final checksum for core  */ -}}
  {{- printf (printf "%s %s" ($pushAdminUser | sha256sum) ($pushAdminPassword | sha256sum) ) | sha256sum -}}
{{- end -}}

{{/*
Define reusable secret checksum for LTPA configuration
*/}}
{{- define "hcl-dx-deployment.ltpaChecksum" -}}
  {{- /* Setting default LTPA values */ -}}
  {{- $ltpaVersion := .Values.configuration.core.ltpa.version }}
  {{- $ltpaRealm := .Values.configuration.core.ltpa.realm }}
  {{- $ltpaDesKey := .Values.configuration.core.ltpa.desKey }}
  {{- $ltpaPrivateKey := .Values.configuration.core.ltpa.privateKey }}
  {{- $ltpaPublicKey := .Values.configuration.core.ltpa.publicKey }}
  {{- $ltpaPassword := .Values.configuration.core.ltpa.password }}

  {{- /* Checking if validations are passed and custom secret is used. If passed then credentials are fetched from the custom secret  */ -}}
  {{- if (eq (include "hcl-dx-deployment.isCustomLTPASecretUsed" .) "true") }}
    {{- $currentCustomLtpaSecret := (lookup "v1" "Secret" .Release.Namespace .Values.configuration.core.ltpa.customLtpaSecret ) }}
    {{- if $currentCustomLtpaSecret }}
      {{- $ltpaVersion = (b64dec (get $currentCustomLtpaSecret.data "ltpa.version")) }}
      {{- $ltpaRealm = (b64dec (get $currentCustomLtpaSecret.data "ltpa.realm")) }}
      {{- $ltpaDesKey = (b64dec (get $currentCustomLtpaSecret.data "ltpa.desKey")) }}
      {{- $ltpaPrivateKey = (b64dec (get $currentCustomLtpaSecret.data "ltpa.privateKey")) }}
      {{- $ltpaPublicKey = (b64dec (get $currentCustomLtpaSecret.data "ltpa.publicKey")) }}
      {{- $ltpaPassword = (b64dec (get $currentCustomLtpaSecret.data "ltpa.password")) }}
    {{- end }}
  {{- end -}}

  {{- /* Creating the final checksum for LTPA configuration  */ -}}
  {{- printf (printf "%s %s %s %s %s %s" ($ltpaVersion | sha256sum) ($ltpaRealm | sha256sum) ($ltpaDesKey | sha256sum) ($ltpaPrivateKey | sha256sum) ($ltpaPublicKey | sha256sum) ($ltpaPassword | sha256sum)) | sha256sum -}}
{{- end -}}

{{/*
Return number of synchronous_standby_names servers
If there is only one persistenceNode replica there are no synchronous standbys. We need to handle this case differently.
If no synchronous standby names are specified, then synchronous replication is not enabled and transaction commits will not wait for replication.
*/}}
{{- define "hcl-dx-deployment.persistence.synchronousStandbyNames" -}}
  {{- if (le (int .Values.scaling.replicas.persistenceNode) 1) }}
    {{- printf "" -}}
  {{- else -}}
    {{- printf "%s (*)" (toString (sub .Values.scaling.replicas.persistenceNode 1)) -}}
  {{- end -}}
{{- end -}}

{{/*
Enable MHS License Check in Production Environment to track Usage
*/}}
{{- define "hcl-dx-deployment.productionEnvironment" -}}
  {{- if (.Values.configuration.licenseManager.productionEnvironment) }}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end }}

{{/*
Enable Stub mode
*/}}
{{- define "hcl-dx-deployment.stubMode" -}}
  {{- if (.Values.incubator.configuration.damPluginGoogleVision.stubMode) }}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end }}

{{/*

{{/*
MHS License Server URI
*/}}
{{- define "hcl-dx-deployment.licenseServerUri" -}}
  {{- printf .Values.configuration.licenseManager.licenseServerUri -}}
{{- end }}

{{/*
Helper function to check if a secret is deployed in the namespace and all data attributes are present.
This function accepts a dictionary as input with the following keys:
  "secretName" is the name of the secret to check
  "requiredDataAttributes" must be a list of data attributes to check
  "globalScope" passes in the global scope to be restored in this context. (will be "." in most cases)
*/}}

{{- define "hcl-dx-deployment.checkSecretAndDataExists" -}}
  {{- /* Keep the input scope available under $input. This holds all parameters passed to the defined function */ -}}
  {{- $input := . }}
  {{- /* Restore the global scope to access known variables using the dot notation (e.g. .Release.Name) */ -}}
  {{- with $input.globalScope -}}
    {{- /* Try to lookup the provided secret */ -}}
    {{- $currentSecret := (lookup "v1" "Secret" .Release.Namespace $input.secretName ) -}}
    {{- /* Throw an error if the secret is not yet deployed in the namespace */ -}}
    {{- if not $currentSecret -}}
      {{- fail (printf "The secret '%s' was set in the values  but it could not be found in the namespace '%s' in Kubernetes. Please make sure the secrets were added to the cluster before deploying DX." $input.secretName .Release.Namespace ) -}}
    {{- end }}
    
    {{- $errors := list -}}
    {{- /* Make sure all required attributes are set in the secrets "data" field */ -}}
    {{- range $requiredValue := $input.requiredDataAttributes -}}
      {{- if not (get $currentSecret.data $requiredValue) -}}
        {{- $errors = append $errors $requiredValue -}}
      {{- end }}
    {{- end }}
    {{- /* If one or more attributes are missing we throw an error */ -}}
    {{- if not (empty $errors) -}}
      {{- fail (printf "The secret '%s' is missing the required value(s) '%s' in its data." $input.secretName (join ", " $errors)) -}}
    {{- end }}
  {{- end }}
{{- end}}

{{/*
WPS Secret used to get the WPS admin credentials
*/}}
{{- define "hcl-dx-deployment.isCustomWpsSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.core.customWpsSecret) (or .Values.security.core.wpsUser .Values.security.core.wpsPassword) }}
    {{- fail "Either security.core.wpsUser or security.core.wpsPassword are set even though a custom secret was provided in security.core.customWpsSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.core.customWpsSecret)) (not (.Values.security.core.wpsUser)) }}
    {{- fail "Please provide a credential setup for the WPS admin user by either setting security.core.wpsUser and security.core.wpsPassword or by referencing a secret in security.core.customWpsSecret" }}
  {{- else if (.Values.security.core.customWpsSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.core.customWpsSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
WPS Secret used to get the WPS admin credentials
*/}}
{{- define "hcl-dx-deployment.iscustomWebEngineSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.webEngine.customWebEngineSecret) (or .Values.security.webEngine.webEngineUser .Values.security.webEngine.webEnginePassword) }}
    {{- fail "Either security.webEngine.webEngineUser or security.webEngine.webEnginePassword are set even though a custom secret was provided in security.webEngine.customWebEngineSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.webEngine.customWebEngineSecret)) (not (.Values.security.webEngine.webEngineUser)) }}
    {{- fail "Please provide a credential setup for the WPS admin user by either setting security.webEngine.webEngineUser and security.webEngine.webEnginePassword or by referencing a secret in security.webEngine.customWebEngineSecret" }}
  {{- else if (.Values.security.webEngine.customWebEngineSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.webEngine.customWebEngineSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
WAS Secret used to get the WAS admin credentials
*/}}
{{- define "hcl-dx-deployment.isCustomWasSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.core.customWasSecret) (or .Values.security.core.wasUser .Values.security.core.wasPassword) }}
    {{- fail "Either security.core.wasUser or security.core.wasPassword are set even though a custom secret was provided in security.core.customWasSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.core.customWasSecret)) (not (.Values.security.core.wasUser)) }}
    {{- fail "Please provide a credential setup for the WAS admin user by either setting security.core.wasUser and security.core.wasPassword or by referencing a secret in security.core.customWasSecret" }}
  {{- else if (.Values.security.core.customWasSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.core.customWasSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Config Wizard Secret used to get the Config Wizard admin credentials
*/}}
{{- define "hcl-dx-deployment.isCustomConfigWizardSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.core.customConfigWizardSecret) (or .Values.security.core.configWizardUser .Values.security.core.configWizardPassword) }}
    {{- fail "Either security.core.configWizardUser or security.core.configWizardPassword are set even though a custom secret was provided in security.core.customConfigWizardSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.core.customConfigWizardSecret)) (not (.Values.security.core.configWizardUser)) }}
    {{- fail "Please provide a credential setup for the Config Wizard admin user by either setting security.core.configWizardUser and security.core.configWizardPassword or by referencing a secret in security.core.customConfigWizardSecret" }}
  {{- else if (.Values.security.core.customConfigWizardSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.core.customConfigWizardSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
DAM Google Vision Secret used to get the Authentication and API Keys
*/}}
{{- define "hcl-dx-deployment.isCustomDamGoogleVisionSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.damPluginGoogleVision.customDamGoogleVisionSecret) (or .Values.security.damPluginGoogleVision.authenticationKey .Values.security.damPluginGoogleVision.apiKey) }}
    {{- fail "Either security.damPluginGoogleVision.apiKey or security.damPluginGoogleVision.authenticationKey are set even though a custom secret was provided in security.damPluginGoogleVision.customDamGoogleVisionSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.damPluginGoogleVision.customDamGoogleVisionSecret)) (not (.Values.security.damPluginGoogleVision.authenticationKey)) }}
    {{- fail "Please provide a credential setup for the DAM Google Vision Authentication key by either setting security.damPluginGoogleVision.authenticationKey and security.damPluginGoogleVision.apiKey or by referencing a secret in security.damPluginGoogleVision.customDamGoogleVisionSecret" }}
  {{- else if (.Values.security.damPluginGoogleVision.customDamGoogleVisionSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "authenticationKey" "apiKey") "secretName" .Values.security.damPluginGoogleVision.customDamGoogleVisionSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
DAM Kaltura Secret used to get the Authentication and Secret Keys
*/}}
{{- define "hcl-dx-deployment.isCustomDamKalturaSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.damPluginKaltura.customDamKalturaSecret) (or .Values.security.damPluginKaltura.authenticationKey .Values.security.damPluginKaltura.secretKey) }}
    {{- fail "Either security.damPluginKaltura.secretKey or security.damPluginKaltura.authenticationKey are set even though a custom secret was provided in security.damPluginKaltura.customDamKalturaSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.damPluginKaltura.customDamKalturaSecret)) (not (.Values.security.damPluginKaltura.authenticationKey)) }}
    {{- fail "Please provide a credential setup for the DAM Kaltura Authentication key by either setting security.damPluginKaltura.authenticationKey and security.damPluginKaltura.secretKey or by referencing a secret in security.damPluginKaltura.customDamKalturaSecret" }}
  {{- else if (.Values.security.damPluginKaltura.customDamKalturaSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "authenticationKey" "secretKey") "secretName" .Values.security.damPluginKaltura.customDamKalturaSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Image Processor Secret used to get the Authentication for Plugin APIs
*/}}
{{- define "hcl-dx-deployment.isCustomImageProcessorSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.imageProcessor.customImageProcessorSecret) (.Values.security.imageProcessor.authenticationKey) }}
    {{- fail "security.imageProcessor.authenticationKey is set even though a custom secret was provided in security.imageProcessor.customImageProcessorSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.imageProcessor.customImageProcessorSecret)) (not (.Values.security.imageProcessor.authenticationKey)) }}
    {{- fail "Please provide a credential setup for the Image Processor Authentication by either setting security.imageProcessor.authenticationKey or by referencing a secret in security.imageProcessor.customImageProcessorSecret" }}
  {{- else if (.Values.security.imageProcessor.customImageProcessorSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "authenticationKey") "secretName" .Values.security.imageProcessor.customImageProcessorSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
AI Secret used to get the API Keys of AI Service
*/}}
{{- define "hcl-dx-deployment.isCustomContentAISecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.core.customContentAISecret) (.Values.security.core.contentAIProviderAPIKey) }}
    {{- fail "Either security.core.contentAIProviderAPIKey are set even though a custom secret was provided in security.core.customContentAISecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- else if (.Values.security.core.customContentAISecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "apiKey") "secretName" .Values.security.core.customContentAISecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
WebEngine: AI Secret used to get the API Keys of AI Service
*/}}
{{- define "hcl-dx-deployment.isCustomWebEngineContentAISecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.webEngine.customWebEngineContentAISecret) (.Values.security.webEngine.webEngineContentAIProviderAPIKey) }}
    {{- fail "Either security.webEngine.webEngineContentAIProviderAPIKey are set even though a custom secret was provided in security.webEngine.customWebEngineContentAISecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- else if (.Values.security.webEngine.customWebEngineContentAISecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "apiKey") "secretName" .Values.security.webEngine.customWebEngineContentAISecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
LDAP Secret used to get the Open LDAP credentials
*/}}
{{- define "hcl-dx-deployment.isCustomLdapSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.openLdap.customLdapSecret) (or .Values.security.openLdap.ldapUser .Values.security.openLdap.ldapPassword) }}
    {{- fail "Either security.openLdap.ldapUser or security.openLdap.ldapPassword are set even though a custom secret was provided in security.openLdap.customLdapSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.openLdap.customLdapSecret)) (not (.Values.security.openLdap.ldapUser)) }}
    {{- fail "Please provide a credential setup for the Open LDAP user by either setting security.openLdap.ldapUser and security.openLdap.ldapPassword or by referencing a secret in security.openLdap.customLdapSecret" }}
  {{- else if (.Values.security.openLdap.customLdapSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.openLdap.customLdapSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Remote Search Secret used to get the WAS admin credentials
*/}}
{{- define "hcl-dx-deployment.isCustomRemoteSearchSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.remoteSearch.customWasSecret) (or .Values.security.remoteSearch.wasUser .Values.security.remoteSearch.wasPassword) }}
    {{- fail "Either security.remoteSearch.wasUser or security.remoteSearch.wasPassword are set even though a custom secret was provided in security.remoteSearch.customWasSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.remoteSearch.customWasSecret)) (not (.Values.security.remoteSearch.wasUser)) }}
    {{- fail "Please provide a credential setup for the Remote Search WAS admin user by either setting security.remoteSearch.wasUser and security.remoteSearch.wasPassword or by referencing a secret in security.remoteSearch.customWasSecret" }}
  {{- else if (.Values.security.remoteSearch.customWasSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.remoteSearch.customWasSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Connection Pool Secret used to get the Persistence Connection Pool admin credentials
*/}}
{{- define "hcl-dx-deployment.isCustomConnectionPoolSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.persistence.customConnectionPoolSecret) (or .Values.security.persistence.connectionPoolAdmin .Values.security.persistence.connectionPoolPassword) }}
    {{- fail "Either security.persistence.connectionPoolAdmin or security.persistence.connectionPoolPassword are set even though a custom secret was provided in security.persistence.customConnectionPoolSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.persistence.customConnectionPoolSecret)) (not (.Values.security.persistence.connectionPoolAdmin)) }}
    {{- fail "Please provide a credential setup for the Connection Pool credentials by either setting security.persistence.connectionPoolAdmin and security.persistence.connectionPoolPassword or by referencing a secret in security.persistence.customConnectionPoolSecret" }}
  {{- else if (.Values.security.persistence.customConnectionPoolSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.persistence.customConnectionPoolSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
DAM Secret used to get the DAM user credentials
*/}}
{{- define "hcl-dx-deployment.isCustomDamSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.digitalAssetManagement.customDamSecret) (or .Values.security.digitalAssetManagement.damUser .Values.security.digitalAssetManagement.damPassword) }}
    {{- fail "Either security.digitalAssetManagement.damUser or security.digitalAssetManagement.damPassword are set even though a custom secret was provided in security.digitalAssetManagement.customDamSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.digitalAssetManagement.customDamSecret)) (not (.Values.security.digitalAssetManagement.damUser)) }}
    {{- fail "Please provide a credential setup for the DAM user credentials by either setting security.digitalAssetManagement.damUser and security.digitalAssetManagement.damPassword or by referencing a secret in security.digitalAssetManagement.customDamSecret" }}
  {{- else if (.Values.security.digitalAssetManagement.customDamSecret) }}
    {{- $damSecret := (lookup "v1" "Secret" .Release.Namespace .Values.security.digitalAssetManagement.customDamSecret ) }}
    {{- $damUser := (b64dec (get $damSecret.data "username")) }}
      {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
      {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.digitalAssetManagement.customDamSecret "globalScope" . ) -}}
          {{- if regexMatch "^[a-z_][a-z0-9_$]{0,62}$" $damUser }}
            {{- printf "true" -}}
          {{- else }}
            {{- fail "User name format is incorrect in security.digitalAssetManagement.customDamSecret. The user name can begin with lowercase alphabets or underscore and can contain only lowercase alphabets, numbers, underscore or dollar sign with max length of 63 characters" }}
          {{- end }}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Replication Secret used to get the Replication credentials
*/}}
{{- define "hcl-dx-deployment.isCustomReplicationSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.digitalAssetManagement.customReplicationSecret) (or .Values.security.digitalAssetManagement.replicationUser .Values.security.digitalAssetManagement.replicationPassword) }}
    {{- fail "Either security.digitalAssetManagement.replicationUser or security.digitalAssetManagement.replicationPassword are set even though a custom secret was provided in security.digitalAssetManagement.customReplicationSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.digitalAssetManagement.customReplicationSecret)) (not (.Values.security.digitalAssetManagement.replicationUser)) }}
    {{- fail "Please provide a credential setup for the Replication credentials by either setting security.digitalAssetManagement.replicationUser and security.digitalAssetManagement.replicationPassword or by referencing a secret in security.digitalAssetManagement.customReplicationSecret" }}
  {{- else if (.Values.security.digitalAssetManagement.customReplicationSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.digitalAssetManagement.customReplicationSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
DAM DB Secret used to get the DB credentials
*/}}
{{- define "hcl-dx-deployment.isCustomDBSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.digitalAssetManagement.customDBSecret) (or .Values.security.digitalAssetManagement.dbUser .Values.security.digitalAssetManagement.dbPassword) }}
    {{- fail "Either security.digitalAssetManagement.dbUser or security.digitalAssetManagement.dbPassword are set even though a custom secret was provided in security.digitalAssetManagement.customDBSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.digitalAssetManagement.customDBSecret)) (not (.Values.security.digitalAssetManagement.dbUser)) }}
    {{- fail "Please provide a credential setup for the DAM DB credentials by either setting security.digitalAssetManagement.dbUser and security.digitalAssetManagement.dbPassword or by referencing a secret in security.digitalAssetManagement.customDBSecret" }}
  {{- else if (.Values.security.digitalAssetManagement.customDBSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.digitalAssetManagement.customDBSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
DAM Crud user Secret used to get the DB credentials
*/}}
{{- define "hcl-dx-deployment.isCustomDamCrudSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.security.digitalAssetManagement.customDamSecret) (or .Values.security.digitalAssetManagement.damUser .Values.security.digitalAssetManagement.damPassword) }}
    {{- fail "Either security.digitalAssetManagement.damUser or security.digitalAssetManagement.damPassword are set even though a custom secret was provided in security.digitalAssetManagement.customDamSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.security.digitalAssetManagement.customDamSecret)) (not (.Values.security.digitalAssetManagement.damUser)) }}
    {{- fail "Please provide a credential setup for the DAM DB credentials by either setting security.digitalAssetManagement.damUser and security.digitalAssetManagement.dbPassword or by referencing a secret in security.digitalAssetManagement.customDamSecret" }}
  {{- else if (.Values.security.digitalAssetManagement.customDamSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.security.digitalAssetManagement.customDBSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Search Middleware Push Admin Secret used to get the credentials
*/}}
{{- define "hcl-dx-deployment.isCustomPushAdminSecretUsed" -}}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.configuration.searchMiddleware.customPushAdminSecret) (or .Values.configuration.searchMiddleware.pushAdminUser .Values.configuration.searchMiddleware.pushAdminPassword) }}
    {{- fail "Either configuration.searchMiddleware.pushAdminUser or configuration.searchMiddleware.pushAdminPassword are set even though a custom secret was provided in configuration.searchMiddleware.customPushAdminSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.configuration.searchMiddleware.customPushAdminSecret)) (not (.Values.configuration.searchMiddleware.pushAdminUser)) }}
    {{- fail "Please provide a credential setup for the Search Push Admin credentials by either setting configuration.searchMiddleware.pushAdminUser and configuration.searchMiddleware.pushAdminPassword or by referencing a secret in configuration.searchMiddleware.customPushAdminSecret" }}
  {{- else if (.Values.configuration.searchMiddleware.customPushAdminSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "username" "password") "secretName" .Values.configuration.searchMiddleware.customPushAdminSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
LTPA Secret used to get the LTPA configurations
*/}}
{{- define "hcl-dx-deployment.isCustomLTPASecretUsed" -}}
  {{- if (.Values.configuration.core.ltpa.enabled) }}
  {{- /* Error: Credentials are set both via values as well as secret */ -}}
  {{- if and (.Values.configuration.core.ltpa.customLtpaSecret) (or .Values.configuration.core.ltpa.password .Values.configuration.core.ltpa.version .Values.configuration.core.ltpa.realm .Values.configuration.core.ltpa.desKey .Values.configuration.core.ltpa.privateKey .Values.configuration.core.ltpa.publicKey) }}
    {{- fail "Either configuration.core.ltpa values are set even though a custom secret was provided in configuration.core.ltpa.customLtpaSecret. Please explicitly set the unused credentials to be empty/null" }}
  {{- /* Error: Neither of the options to set credentials is used */ -}}
  {{- else if and (not (.Values.configuration.core.ltpa.customLtpaSecret)) (not (and .Values.configuration.core.ltpa.password .Values.configuration.core.ltpa.version .Values.configuration.core.ltpa.realm .Values.configuration.core.ltpa.desKey .Values.configuration.core.ltpa.privateKey .Values.configuration.core.ltpa.publicKey)) }}
    {{- fail "Please provide a configuration for LTPA by either setting Values.configuration.core.ltpa values or by referencing a secret in configuration.core.ltpa.customLtpaSecret" }}
  {{- else if (.Values.configuration.core.ltpa.customLtpaSecret) }}
    {{- /* Custom secret is used. Check if it is present and correct in the namespace */ -}}
    {{- include "hcl-dx-deployment.checkSecretAndDataExists" (dict "requiredDataAttributes" (list "ltpa.version" "ltpa.realm"  "ltpa.desKey" "ltpa.privateKey"  "ltpa.publicKey" "ltpa.password") "secretName" .Values.configuration.core.ltpa.customLtpaSecret "globalScope" . ) -}}
    {{- printf "true" -}}
  {{- else }}
    {{- /* Fallback to legacy credential secret */ -}}
    {{- printf "false" -}}
  {{- end }}
  {{- end }}
{{- end }}

{{/*
  Logic to determine if Remote Search can be autoconfigured or not
  Remote Search will only be configured if both Core and Remote Search are enabled
*/}}
{{- define "hcl-dx-deployment.configureRemoteSearch" -}}
  {{- if and (.Values.configuration.remoteSearch.autoConfigure) (eq (include "hcl-dx-deployment.coreEnabled" .) "true") (eq (include "hcl-dx-deployment.remoteSearchEnabled" .) "true") }}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end }}
{{- end }}

{{/*
Enable Clean up and rendition version regeneration jobs for DAM
*/}}
{{- define "hcl-dx-deployment.enableCleanUpOrRenditionVersionHeartbeats" -}}
  {{- if (.Values.configuration.digitalAssetManagement.enableCleanUpOrRenditionVersionHeartbeats) }}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end }}
{{/*
To generate a random password, the following steps have been follow:
1. Create a list that contains random lowercase letters, random numeric characters, and random uppercase letters. Join the elements of the list into a single string, separated by "_" character.
2. Use the randAscii function to generate a random string consisting of ASCII characters. You can specify the length of the string you want to generate default is 10.
3. Remove any non-word characters from the generated password to ensure that it only contains valid characters. 
Usage:
{{ include "hcl-dx-deployment.generateRandomPassword" (dict "length" 10) }}

Params:
  - length: int - Optional - Length of the generated random password.
*/}}
{{- define "hcl-dx-deployment.generateRandomPassword" -}}

{{- $password := "" }}
{{- $passwordLength := default 10 .length }}
  {{- $subStr := list (lower (randAlpha 1)) (randNumeric 1) (upper (randAlpha 1)) | join "_" }}
  {{- $password := randAscii $passwordLength }} 
  {{- $password = regexReplaceAllLiteral "\\W" $password "" | substr 5 $passwordLength }}
  {{- printf "%s%s" $subStr $password | toString | shuffle }}
{{- end -}}

{{/*
Returns the service account name to be used for the deployment based on global and license manager service account name.
*/}}
{{- define "hcl-dx-deployment.serviceAccountName" -}}
  {{- if .Values.global.serviceAccountName }}
    {{- print .Values.global.serviceAccountName }}
  {{- else if .Values.configuration.licenseManager.serviceAccountName }}
    {{- print .Values.configuration.licenseManager.serviceAccountName }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{/*
  DAM persistence database host name.
  If host name is specified in values yaml, then it is considered as External Database.
  Else the Internal service name of DB will be considered as Database host name
*/}}
{{- define "hcl-dx-deployment.damDatabaseHost" -}}
  {{- if .Values.configuration.persistence.host -}}
    {{- printf .Values.configuration.persistence.host }}
  {{- else -}}
    {{- printf .Release.Name -}}{{- printf "-persistence" -}}
  {{- end -}}
{{- end -}}

{{/*
  DAM init configuration
*/}}
{{- define "hcl-dx-deployment.damDbInitByDam" -}}
  {{- if .Values.configuration.digitalAssetManagement.newDbManagement -}}
    {{- printf "false" }}
  {{- else -}}
    {{- toString .Values.incubator.configuration.persistence.dbInitByDam }}
  {{- end -}}
{{- end -}}

{{/* Validation for IQ Secret existence */}}
{{- define "hcl-dx-deployment.validateIqSecret" -}}
{{- if .Values.incubator.security.iq.customDbSecret -}}
  {{- $secretName := .Values.incubator.security.iq.customDbSecret -}}
  {{- if (lookup "v1" "Secret" .Release.Namespace $secretName) -}}
    {{- /* Secret found, do nothing */ -}}
  {{- else if .Release.IsInstall -}}
    {{- /* Only fail during actual install/upgrade if secret is missing */ -}}
    {{- fail (printf "IQ database secret '%s' not found in namespace '%s'. Please create it before deploying." $secretName .Release.Namespace) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

