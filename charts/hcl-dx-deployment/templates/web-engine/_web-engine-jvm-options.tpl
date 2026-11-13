{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2024, 2025. All Rights Reserved. *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{- define "hcl-dx-deployment.webEngineJvmOptions" -}}
-Dicm.config.file.dir=./libraries/dxcoreLib/com/ibm/icm/icm.properties
-noverify
-Xms2560m
-Xmn1024m
-Xlog:gc*:file=verbosegc.log:time
-Dfile.encoding=UTF-8
-Ddefault.client.encoding=UTF-8
-Djava.locale.useOldISOCodes=true
{{- if (.Values.configuration.webEngine.debug) }}
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:{{ include "hcl-dx-deployment.ports.webEngine.debug" . }}
{{- end }}
{{- end }}
