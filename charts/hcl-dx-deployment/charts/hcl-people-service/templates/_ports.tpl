{{/*
  API service port logic 
*/}}
{{- define "hcl-people-service.servicePort" -}}
  {{- if (eq (include "hcl-people-service.serviceType" .) "NodePort") }}
    {{- printf toString (.Values.service.ports.nodePort) }}
  {{- else }}
    {{- printf toString (.Values.service.ports.http) }}
  {{- end }}
{{- end -}}
