#********************************************************************
#* Licensed Materials - Property of HCL                             *
#*                                                                  *
#* Copyright HCL Technologies Ltd. 2024 All Rights Reserved.        *
#*                                                                  *
#* Note to US Government Users Restricted Rights:                   *
#*                                                                  *
#* Use, duplication or disclosure restricted by GSA ADP Schedule    *
#********************************************************************

{{- define "hcl-dx-deployment.dbTypeSecret" -}}
{{/* Iterate over all .Values.configuration.webEngine.dbTypeProperties keys and print them as key=value pairs */}}
{{- range $key, $value := .Values.configuration.webEngine.dbTypeProperties }}
{{ $key }}={{ $value }}
{{- end }}
{{- end }}
