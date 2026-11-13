{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2022. All Rights Reserved.       *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
This file is a central place to reuse ports in different places
of the applications
*/}}

{{/*
Core Ports
*/}}

{{- define "hcl-dx-deployment.ports.core.dxHome" -}}
  {{- printf "10039" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.dxHomeSecure" -}}
  {{- printf "10042" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.wasAdmin" -}}
  {{- printf "10038" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.wasAdminSecure" -}}
  {{- printf "10041" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.wasSoap" -}}
  {{- printf "10033" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.cwHome" -}}
  {{- printf "10200" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.cwHomeSecure" -}}
  {{- printf "10202" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.bootstrap" -}}
  {{- printf "10035" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.core.cwAdminSec" -}}
  {{- printf "10203" -}}
{{- end -}}

{{/*
Web Engine Ports
*/}}

{{- define "hcl-dx-deployment.ports.webEngine.dxHome" -}}
  {{- printf "9080" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.webEngine.dxHomeSecure" -}}
  {{- printf "9443" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.webEngine.debug" -}}
  {{- printf "7777" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.webEngine.metrics" -}}
  {{- printf "9091" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.webEngine.soap" -}}
  {{- printf "10033" -}}
{{- end -}}

{{/*
Node.js Applications Ports
*/}}

{{- define "hcl-dx-deployment.ports.global.nodeApplication" -}}
  {{- printf "3000" -}}
{{- end -}}

{{/*
HAProxy Ports
*/}}

{{- define "hcl-dx-deployment.ports.haproxy.metrics" -}}
  {{- printf "8404" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.haproxy.serverContainerPort" -}}
  {{- printf "8081" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.haproxy.socketPort" -}}
  {{- printf "9999" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.haproxy.probe" -}}
  {{- printf "10001" -}}
{{- end -}}

{{/*
License Manager Ports
*/}}

{{- define "hcl-dx-deployment.ports.licenseManager.serverContainerPort" -}}
  {{- printf "5656" -}}
{{- end -}}

{{/*
Remote Search Ports
*/}}

{{- define "hcl-dx-deployment.ports.remoteSearch.wasAdmin" -}}
  {{- printf "9060" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.remoteSearch.wasAdminSecure" -}}
  {{- printf "9043" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.remoteSearch.boot" -}}
  {{- printf "2809" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.remoteSearch.rs" -}}
  {{- printf "9403" -}}
{{- end -}}

{{/*
Persistence Ports
*/}}

{{- define "hcl-dx-deployment.ports.persistence.metrics" -}}
  {{- printf "9187" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.persistence.repmgr" -}}
  {{- printf "5432" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.persistence.pgpool" -}}
  {{- printf "5432" -}}
{{- end -}}

{{/*
OpenLDAP Ports
*/}}

{{- define "hcl-dx-deployment.ports.openldap.ldap" -}}
  {{- printf "1389" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.openldap.ldaps" -}}
  {{- printf "1636" -}}
{{- end -}}

{{- define "hcl-dx-deployment.ports.openldap.ldapi" -}}
  {{- printf "1666" -}}
{{- end -}}