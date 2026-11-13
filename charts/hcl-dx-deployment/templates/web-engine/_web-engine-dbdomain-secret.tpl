#********************************************************************
#* Licensed Materials - Property of HCL                             *
#*                                                                  *
#* Copyright HCL Technologies Ltd. 2024 All Rights Reserved.        *
#*                                                                  *
#* Note to US Government Users Restricted Rights:                   *
#*                                                                  *
#* Use, duplication or disclosure restricted by GSA ADP Schedule    *
#********************************************************************

{{- define "hcl-dx-deployment.dbDomainSecret" -}}
{{/* Iterate over all .Values.configuration.webEngine.dbDomainProperties keys and print them as key=value pairs */}}
{{- range $key, $value := .Values.configuration.webEngine.dbDomainProperties }}
{{ $key }}={{ $value }}
{{- end }}
{{- end }}
