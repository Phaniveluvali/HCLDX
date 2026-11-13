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
  CONFIG MAP KEYS AND VALUES MUST BE ENCLOSED IN DOUBLE QUOTES
  CONFIG MAP KEYS MUST BE SORTED ALPHABETICALLY
  ENTRIES MUST BE TRIMMED MANUALLY + 1 WHITESPACE AFTER COLON
*/}}

{{- define "hcl-dx-deployment.digitalAssetManagementConfig" -}}
"dam.config.dam.acl_cache_ttl": "{{ .Values.configuration.digitalAssetManagement.aclCacheTtl | int }}"
"dam.config.dam.acl_traversal": "{{ .Values.configuration.digitalAssetManagement.aclTraversal }}"
"dam.config.dam.allow_editor_to_create_collections": "{{ .Values.configuration.digitalAssetManagement.allowEditorToCreateCollections }}"
"dam.config.dam.auth_cache_ttl": "{{ .Values.configuration.digitalAssetManagement.authCacheTtl | int }}"
"dam.config.dam.base_api_external_ssl_enabled": "{{ include "hcl-dx-deployment.externalAddonSsl" . }}"
"dam.config.dam.clean_up_heartbeat_interval_time_minutes": "{{ .Values.configuration.digitalAssetManagement.cleanUpHeartbeatIntervalTimeInMinutes | int }}"
"dam.config.dam.core_api_context_root": "{{ include "hcl-dx-deployment.contextRoot" . }}"
"dam.config.dam.core_api_host": "{{ include "hcl-dx-deployment.internalCoreHost" . }}"
"dam.config.dam.core_api_port": "{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }}"
"dam.config.dam.core_api_ssl_enabled": "{{ include "hcl-dx-deployment.internalCoreSsl" . }}"
"dam.config.dam.cors_origin": "{{ include "hcl-dx-deployment.digitalAssetManagementCorsOrigin" . }}"
{{- $port_number := include "hcl-dx-deployment.ports.global.nodeApplication" .}}
"dam.config.dam.crop_aspect_ratio": "{{- join "," .Values.configuration.digitalAssetManagement.cropAspectRatio }}"
"dam.config.dam.dam_schema_migration_expired_time_in_minutes": "{{ .Values.configuration.digitalAssetManagement.damSchemaMigrationExpiredTimeInMinutes | int }}"
"dam.config.dam.db_init_by_dam": "{{ include "hcl-dx-deployment.damDbInitByDam" . }}"
"dam.config.dam.default_collection_fetch_limit": "{{ .Values.configuration.digitalAssetManagement.defaultCollectionFetchLimit | int }}"
"dam.config.dam.deployment_name": "{{ .Release.Name }}"
"dam.config.dam.enable_clean_up_or_rendition_version_regeneration_heartbeats": "{{ include "hcl-dx-deployment.enableCleanUpOrRenditionVersionHeartbeats" . }}"
"dam.config.dam.enable_root_collection_sort": "{{ .Values.incubator.configuration.digitalAssetManagement.enableRootCollectionSort }}"
"dam.config.dam.enable_soft_delete": "{{ .Values.incubator.configuration.digitalAssetManagement.enableSoftDelete }}"
"dam.config.dam.enable_trash_auto_clearance": "{{ .Values.incubator.configuration.digitalAssetManagement.enableTrashAutoClearance }}"
"dam.config.dam.event_list_length": "{{ .Values.configuration.digitalAssetManagement.eventListLength | int }}"
"dam.config.dam.extensibility_plugin_config.json": | {{ toPrettyJson .Values.configuration.digitalAssetManagement.pluginsConfiguration | replace "RELEASE_NAME" .Release.Name | replace "DAM_HTTP_PORT" $port_number | nindent 2 }}
"dam.config.dam.extensibility_rendition_config.json": | {{ toPrettyJson .Values.configuration.digitalAssetManagement.renditionsConfiguration | nindent 2 }}
"dam.config.dam.external_base_api_host": "{{ include "hcl-dx-deployment.externalAddonHost" . }}"
"dam.config.dam.external_base_api_port": "{{ include "hcl-dx-deployment.externalAddonPort" . }}"
"dam.config.dam.external_image_processor_api_host": "{{ include "hcl-dx-deployment.externalAddonHost" . }}"
"dam.config.dam.external_image_processor_api_port": "{{ include "hcl-dx-deployment.externalAddonPort" . }}"
"dam.config.dam.external_ring_api_host": "{{ include "hcl-dx-deployment.externalAddonHost" . }}"
"dam.config.dam.external_ring_api_port": "{{ include "hcl-dx-deployment.externalAddonPort" . }}"
"dam.config.dam.failed_operation_threshold_limit_records": "{{ .Values.configuration.digitalAssetManagement.failedOperationThresholdLimitRecords | int }}"
"dam.config.dam.failed_operation_threshold_time_hours": "{{ .Values.configuration.digitalAssetManagement.failedOperationThresholdTimeHours | int }}"
"dam.config.dam.friendly_url_context_root": "{{ .Values.configuration.digitalAssetManagement.friendlyUrlContextRoot }}"
"dam.config.dam.image_processor_api_external_ssl_enabled": "{{ include "hcl-dx-deployment.externalAddonSsl" . }}"
"dam.config.dam.image_processor_api_host": "{{ .Release.Name }}-image-processor"
"dam.config.dam.image_processor_api_port": "{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }}"
"dam.config.dam.image_processor_api_ssl_enabled": "false"
"dam.config.dam.internal_base_api_host": "{{ .Release.Name }}-digital-asset-management"
"dam.config.dam.internal_base_api_port": "{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }}"
"dam.config.dam.last_scan_threshold_time_minutes": "{{ .Values.configuration.digitalAssetManagement.lastScanThresholdTimeInMinutes | int }}"
"dam.config.dam.ltpa_token_refresh_time_in_minutes": "{{ .Values.configuration.digitalAssetManagement.ltpaTokenRefreshTimeInMinutes | int }}"
"dam.config.dam.max_age": "{{ .Values.configuration.digitalAssetManagement.maxAge | int }}"
"dam.config.dam.max_bulk_upload_without_warning": "{{ .Values.configuration.digitalAssetManagement.maxBulkUploadWithoutWarning | int }}"
"dam.config.dam.max_records_to_compare": "{{ .Values.configuration.digitalAssetManagement.maxRecordsToCompare | int }}"
"dam.config.dam.max_validation_processing_limit": "{{ .Values.configuration.digitalAssetManagement.maxValidationProcessingLimit | int }}"
"dam.config.dam.media_creation_threshold_time_minutes": "{{ .Values.configuration.digitalAssetManagement.mediaCreationThresholdTimeInMinutes | int }}"
"dam.config.dam.node_request_timeout_in_minutes": "{{ .Values.configuration.digitalAssetManagement.nodeRequestTimeoutInMinutes | int }}"
"dam.config.dam.operation_clean_up_heart_beat_interval": "{{ .Values.configuration.digitalAssetManagement.cleanUpHeartBeatInterval | int }}"
"dam.config.dam.operation_timeout": "{{ .Values.configuration.digitalAssetManagement.operationTimeout | int }}"
"dam.config.dam.operation_worker_limit": "{{ .Values.configuration.digitalAssetManagement.operationWorkerLimit | int }}"
"dam.config.dam.orphan_data_and_file_cleanup_heartbeat_interval_time_minutes": "{{ .Values.configuration.digitalAssetManagement.orphanDataAndFileCleanupHeartbeatIntervalTimeInMinutes | int }}"
"dam.config.dam.orphan_directory_modification_threshold_time_minutes": "{{ .Values.configuration.digitalAssetManagement.orphanDirectoryModificationThresholdTimeInMinutes | int }}"
"dam.config.dam.orphan_media_storage_creation_threshold_time_minutes": "{{ .Values.configuration.digitalAssetManagement.orphanMediaStorageCreationThresholdTimeInMinutes | int }}"
"dam.config.dam.postgres_db_host": "{{ include "hcl-dx-deployment.damDatabaseHost" . }}"
"dam.config.dam.postgres_db_name": "{{ include "hcl-dx-deployment.damDatabaseName" . }}"
"dam.config.dam.postgres_db_port": "{{ include "hcl-dx-deployment.ports.persistence.pgpool" . }}"
"dam.config.dam.postgres_db_ssl": "{{ .Values.configuration.persistence.ssl }}"
"dam.config.dam.render_new_ui": "{{ .Values.incubator.configuration.digitalAssetManagement.renderNewUI }}"
"dam.config.dam.rendition_or_version_heartbeat_interval_time_minutes": "{{ .Values.configuration.digitalAssetManagement.renditionOrVersionHeartbeatIntervalTimeInMinutes | int }}"
"dam.config.dam.ring_api_external_ssl_enabled": "{{ include "hcl-dx-deployment.externalAddonSsl" . }}"
"dam.config.dam.ring_api_host": "{{ .Release.Name }}-ring-api"
"dam.config.dam.ring_api_port": "{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }}"
"dam.config.dam.ring_api_ssl_enabled": "false"
"dam.config.dam.search_middleware_content_source_id": "{{ .Values.configuration.searchMiddleware.damContentSourceId }}"
"dam.config.dam.search_middleware_external_port": "{{ .Values.configuration.searchMiddleware.port }}"
"dam.config.dam.search_middleware_external_ssl_enabled": "{{ .Values.configuration.searchMiddleware.ssl }}"
"dam.config.dam.search_middleware_host": "{{ .Values.configuration.searchMiddleware.host }}"
"dam.config.dam.search_middleware_is_enabled": "{{ include "hcl-dx-deployment.damIndexingEnabled" . }}"
"dam.config.dam.search_middleware_ssl_enabled": "false"
"dam.config.dam.staging_dam_api_host": "{{ include "hcl-dx-deployment.externalDamStagingHost" . }}"
"dam.config.dam.staging_dam_api_port": "{{ include "hcl-dx-deployment.externalDamStagingPort" . }}"
"dam.config.dam.staging_dam_api_ssl_enabled": "{{ include "hcl-dx-deployment.externalDamStagingSsl" . }}"
"dam.config.dam.staging_ring_api_host": "{{ include "hcl-dx-deployment.externalDamStagingHost" . }}"
"dam.config.dam.staging_ring_api_port": "{{ include "hcl-dx-deployment.externalDamStagingPort" . }}"
"dam.config.dam.staging_ring_api_ssl_enabled": "{{ include "hcl-dx-deployment.externalDamStagingSsl" . }}"
"dam.config.dam.static_max_age": "{{ .Values.configuration.digitalAssetManagement.staticMaxAge | int }}"
"dam.config.dam.trash_clearance_heartbeat_in_minutes": "{{ .Values.incubator.configuration.digitalAssetManagement.trashClearanceHeartbeatInMinutes | int }}"
"dam.config.dam.trash_clearance_time_in_days": "{{ .Values.incubator.configuration.digitalAssetManagement.trashClearanceTimeInDays | int }}"
"dam.config.dam.validation_heartbeat_interval_time_minutes": "{{ .Values.configuration.digitalAssetManagement.validationHeartbeatIntervalTimeInMinutes | int }}"
{{- end -}}
