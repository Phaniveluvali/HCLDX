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

{{- define "hcl-dx-deployment.webEnginePropertiesOverrides" -}}
{{- if .Values.configuration.webEngine.propertiesFilesOverrides -}}
{{- range $name, $config := .Values.configuration.webEngine.propertiesFilesOverrides }}
# We make sure that the file is always mounted as .tpl
{{ trimSuffix ".properties" $name }}.tpl: |
  {{- range $key, $value := $config }}
  {{ $key }}={{ $value }}
  {{- end }}
{{- end }}
{{- end }}
{{- if .Values.configuration.webEngine.propertiesDisable }}
disabled.tpl: |
  {{- range $name, $config := .Values.configuration.webEngine.propertiesDisable }}
  {{- range $key, $value := $config }}
  {{ $name }}={{ $key }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end -}}