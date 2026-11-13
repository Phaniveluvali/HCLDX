    
{{- define "hcl-dx-deployment.corePortList" -}}
- name: "dx-home"
  port: {{ include "hcl-dx-deployment.ports.core.dxHome" . }}
- name: "dx-home-secure"
  port: {{ include "hcl-dx-deployment.ports.core.dxHomeSecure" . }}
- name: "was-admin"
  port: {{ include "hcl-dx-deployment.ports.core.wasAdmin" . }}
- name: "was-admin-secure"
  port: {{ include "hcl-dx-deployment.ports.core.wasAdminSecure" . }}
- name: "was-soap"
  port: {{ include "hcl-dx-deployment.ports.core.wasSoap" . }}
- name: "cw-home"
  port: {{ include "hcl-dx-deployment.ports.core.cwHome" . }}
- name: "cw-home-secure"
  port: {{ include "hcl-dx-deployment.ports.core.cwHomeSecure" . }}
- name: "bootstrap"
  port: {{ include "hcl-dx-deployment.ports.core.bootstrap" . }}
- name: "cw-admin-sec"
  port: {{ include "hcl-dx-deployment.ports.core.cwAdminSec" . }}
{{- end -}}