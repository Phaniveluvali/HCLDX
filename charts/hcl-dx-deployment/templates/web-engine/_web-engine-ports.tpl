    
{{- define "hcl-dx-deployment.webEnginePortList" -}}
- name: "dx-home"
  port: {{ include "hcl-dx-deployment.ports.webEngine.dxHome" . }}
- name: "dx-home-secure"
  port: {{ include "hcl-dx-deployment.ports.webEngine.dxHomeSecure" . }}
{{- if ( .Values.configuration.webEngine.debug) }}
- name: "dx-debug"
  port: {{ include "hcl-dx-deployment.ports.webEngine.debug" . }}
{{- end }}
{{- end -}}