{{- define "hcl-people-service.externalHostUrl" -}}
  {{- if eq (include "hcl-people-service.serviceType" .) "NodePort" }}
    {{- printf "http://%s:%s" .Values.networking.host (int .Values.service.ports.nodePort | toString) }}
  {{- else }}
    {{- printf "%s://%s" (include "hcl-people-service.scheme" .) .Values.networking.host }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.scheme" -}}
  {{- print (ternary "https" "http" (and .Values.networking.ssl.enabled (not (eq (include "hcl-people-service.serviceType" .) "NodePort")))) }}
{{- end -}}

{{- define "hcl-people-service.readonlyFields" -}}
  {{- if .Values.configuration.schema.readonlyFields }}
    {{- print (join "," .Values.configuration.schema.readonlyFields) }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.customFields" -}}
  {{- if .Values.configuration.schema.customFields }}
    {{- print (join "," .Values.configuration.schema.customFields) }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}

{{- define "hcl-people-service.serviceAccountName" -}}
  {{- if .Values.global.serviceAccountName }}
    {{- print .Values.global.serviceAccountName }}
  {{- else if .Values.configuration.serviceAccountName }}
    {{- print .Values.configuration.serviceAccountName }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- end -}}
