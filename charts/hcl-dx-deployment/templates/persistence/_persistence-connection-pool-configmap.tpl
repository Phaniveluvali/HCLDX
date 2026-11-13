{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021, 2023. All Rights Reserved. *
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

{{- define "hcl-dx-deployment.persistenceConnectionPoolConfig" -}}
"dam.config.dam.persistence.pgpool_max_pool": "15"
"dam.config.dam.persistence.pgpool_num_init_children": "64"
"dam.config.dam.persistence.pgpool_sr_check_database": "repmgr"
{{- end -}}