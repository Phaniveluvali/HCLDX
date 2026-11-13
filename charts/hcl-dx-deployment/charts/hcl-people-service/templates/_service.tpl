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

{{- define "hcl-people-service.serviceType" -}}
  {{- if .Values.networking.ingress.enabled -}}
    {{- print "ClusterIP" }}
  {{- else -}}
    {{- print .Values.service.type -}}
  {{- end -}}
{{- end -}}
