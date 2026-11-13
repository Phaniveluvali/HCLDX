{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2022, 2026. All Rights Reserved. *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
  CONFIG MAP KEYS AND VALUES MUST BE ENCLOSED IN DOUBLE QUOTES
  CONFIG MAP KEYS MUST BE SORTED ALPHABETICALLY
  ENTRIES MUST BE TRIMMED MANUALLY + 1 WHITESPACE AFTER COLON
*/}}

{{- define "hcl-dx-deployment.haproxyConfig" -}}
"dx.config.haproxy.cfg": |
  global
    stats socket ipv4@*:{{ include "hcl-dx-deployment.ports.haproxy.socketPort" . }} mode 660 level admin expose-fd listeners
    maxconn 50000
    log stdout format raw local0 info
    nbthread 4
{{- if .Values.networking.haproxy.sslDefaultBindCiphers }}
    ssl-default-bind-ciphers {{ .Values.networking.haproxy.sslDefaultBindCiphers }}
{{- end }}
{{- if .Values.networking.haproxy.sslDefaultBindCiphersuites }}
    ssl-default-bind-ciphersuites {{ .Values.networking.haproxy.sslDefaultBindCiphersuites }}
{{- end }}
{{- if .Values.networking.haproxy.sslDefaultBindOptions }}
    ssl-default-bind-options {{ join " " .Values.networking.haproxy.sslDefaultBindOptions }}
{{- end }}

  defaults
    timeout connect 10s
    timeout client 1200s
    timeout server 1200s
    log global
    mode http
    option httplog
    # If a core server goes down we allow connecting to other servers even if stickyness would prevent that
    option redispatch
    balance leastconn
    # Default http log format with IP removed
    log-format "[%tr] %ft %b/%s %TR/%Tw/%Tc/%Tr/%Ta %ST %B %CC %CS %tsc %ac/%fc/%bc/%sc/%rc %sq/%bq %hr %hs %{+Q}r"

  # Mock frontend returning a 200 code for the probes once HAProxy is up
  frontend probe
    # We disable logging for the probe frontend to not pollute the log
    no log
    bind :{{ include "hcl-dx-deployment.ports.haproxy.probe" . }}
    http-request return status 200 content-type "text/plain" string "OK"

  frontend metrics
    bind *:{{ include "hcl-dx-deployment.ports.haproxy.metrics" . }}
    http-request use-service prometheus-exporter if { path /metrics }
    stats enable
    stats uri /stats
    stats refresh 10s

  # We create a peer section only pointing to the current instance. This persists stick tables during a config reload as the new process reads the tables from the old process
  peers localPeer
    peer local 127.0.0.1:10000

  frontend dx
    bind :{{ include "hcl-dx-deployment.ports.haproxy.serverContainerPort" . }} {{- if (and .Values.networking.haproxy.ssl (ne (include "hcl-dx-deployment.isSofyDeployment" .) "true")) }} ssl crt /etc/ssl/certs/tls.crt {{ end }}

    # HTTP Strict Transport Security(HSTS)
{{- if and (.Values.networking.haproxy.strictTransportSecurity.enabled) (ne (include "hcl-dx-deployment.isSofyDeployment" .) "true") }}
    {{- if and (.Values.networking.haproxy.strictTransportSecurity.includeSubDomains) (and .Values.networking.haproxy.strictTransportSecurity.preload) }}
    http-response set-header Strict-Transport-Security "max-age={{ int .Values.networking.haproxy.strictTransportSecurity.maxAge }}; includeSubDomains; preload;"
    {{- else if (.Values.networking.haproxy.strictTransportSecurity.includeSubDomains) }}
    http-response set-header Strict-Transport-Security "max-age={{ int .Values.networking.haproxy.strictTransportSecurity.maxAge }}; includeSubDomains;"
    {{- else }}
    http-response set-header Strict-Transport-Security "max-age={{ int .Values.networking.haproxy.strictTransportSecurity.maxAge }};"
    {{- end}}
{{- end }}
    
{{- if .Values.networking.haproxy.customHeader }}
  # Set custom headers from configuration
  {{- range $header := .Values.networking.haproxy.customHeader }}
    http-response set-header {{ $header.name }} "{{ $header.value }}"
  {{- end }}
{{- end }}

{{- if .Values.networking.haproxy.deleteHeader }}
  # Delete headers if specified in configuration
  {{- range $headerName := .Values.networking.haproxy.deleteHeader }}
    http-response del-header {{ $headerName }}
  {{- end }}
{{- end }}

{{- if (include "hcl-dx-deployment.friendlyUrlContextRoot" .) }}
    # We need to keep these original request values in variables to use later
    # Otherwise the ACL results change when modifying the path and query
    http-request set-var(txn.initial_path) path
    http-request set-var(txn.binary) urlp(binary)
    http-request set-var(txn.thumbnail) urlp(thumbnail)
    http-request set-var(txn.download) urlp(download)
    http-request set-var(txn.rendition) urlp(rendition)
    http-request set-var(txn.version) urlp(version)
    # Create ACL rules for the URL rewrite referencing the original values
    acl is_custom_path var(txn.initial_path) -m beg /{{ include "hcl-dx-deployment.friendlyUrlContextRoot" . }}/
    acl is_binary_parameter_set var(txn.binary) -m found
    acl is_thumbnail_true var(txn.thumbnail) -m str true
    acl is_download_true var(txn.download) -m str true
    acl is_rendition_parameter_set var(txn.rendition) -m found
    acl is_version_parameter_set var(txn.version) -m found
    # This regex only matches if both collection AND item is supplied
    acl has_collection_and_item var(txn.initial_path) -m reg ^/{{ include "hcl-dx-deployment.friendlyUrlContextRoot" . }}/([^/]*)/([^/]+)/*$
    {{- if .Values.peopleservice.enabled }}    
    acl is_custom_people_ui_path path_beg {{ .Values.peopleservice.networking.contextRoot.ui }}
    acl is_custom_people_api_path path_beg {{ .Values.peopleservice.networking.contextRoot.api }}
    {{- end }}

    # Set default rendition to "Original" if not set explicitly
    http-request set-var(txn.rendition) str("Original") if !is_rendition_parameter_set
    # Set default binary to "true" if not set explicitly
    http-request set-var(txn.binary) str("true") if !is_binary_parameter_set

    # Set the query string according to the binary parameter. This overwrites the initial request query parameters
    http-request set-query "binary=%[var(txn.binary)]" if is_custom_path
    http-request set-query thumbnail=true if is_custom_path is_thumbnail_true
    http-request set-query download=true if is_custom_path is_download_true

    # Modify the path according to the parameters. Resolving the actual DAM path
    # If collection AND item are present we redirect to the item
    http-request set-path %[path,regsub(\"^/{{ include "hcl-dx-deployment.friendlyUrlContextRoot" . }}/([^/]*)/([^/]+)/*$\",\"/dx/api/dam/v1/collections/\1/items/\2\",)] if is_custom_path has_collection_and_item
    # Otherwise only redirect to the collection
    http-request set-path %[path,regsub(\"^/{{ include "hcl-dx-deployment.friendlyUrlContextRoot" . }}/([^/]*)/*$\",\"/dx/api/dam/v1/collections/\1\",)] if is_custom_path !has_collection_and_item

    # Add the rendition path
    http-request set-path %[path]/renditions/%[var(txn.rendition)] if is_custom_path has_collection_and_item
    # Add the version path if set explicitly
    http-request set-path %[path]/versions/%[var(txn.version)] if is_custom_path is_version_parameter_set has_collection_and_item !is_thumbnail_true
{{- end }}

    use_backend dam if { path -m reg ^/dx/(api|ui)/dam/ }
    use_backend dam if { path_beg /dx/ui/picker/ }
    use_backend content if { path_beg /dx/ui/content/ }
    use_backend image-processor if { path_beg /dx/api/image-processor/ }
    use_backend ring-api if { path_beg /dx/api/core/ }
    stick-table type string len 180 size 32m expire 30m store http_req_rate(30m),gpc0 peers localPeer
    http-request set-header X-Concat --%[src]_%[req.fhdr(User-Agent)]_%[req.fhdr(X-Forwarded-For,-1)]--
    http-request track-sc0 req.fhdr(X-Concat)


    use_backend runtime-controller  if { path_beg /dx/api/runtime-controller/ }
  {{- if (.Values.networking.searchMiddlewareService) }}
    use_backend search-middleware-service if { path_beg /dx/api/search/v2/ }
    use_backend search-middleware-service if { path_beg /dx/ui/search/ }
  {{- end }}
  {{- if (.Values.incubator.networking.dxIqService) }}
    use_backend dx-ai-integrator-service if { path_beg /dx/api/iq/v1/ }
    use_backend dx-ai-integrator-service if { path_beg /dx/ui/iq/ }
  {{- end }}
  {{- if .Values.peopleservice.enabled }}
    use_backend people-service-ui if is_custom_people_ui_path
    use_backend people-service-api if is_custom_people_api_path
  {{- end }}

  {{- if eq (include "hcl-dx-deployment.webEngineEnabled" .) "true" }}
    {{- if (.Values.networking.webEngine.cookieSameSiteAttribute) }}
    http-response replace-header Set-Cookie "(WASReqURL.*)" \1;\ SameSite={{ .Values.networking.webEngine.cookieSameSiteAttribute }};\ Secure;
    {{- end }}

    default_backend web-engine-dx-home
  {{- else }}
    {{- if (.Values.networking.core.cookieSameSiteAttribute) }}
    http-response replace-header Set-Cookie "(WASReqURL.*)" \1;\ SameSite={{ .Values.networking.core.cookieSameSiteAttribute }};\ Secure;
    {{- end }}

    {{- if (.Values.configuration.core.exposeConfigurationConsole) }}
    use_backend core-was-admin if { path_beg /ibm/console/ }
    {{- end }}

    {{- if .Values.configuration.core.tuning.configWizard }}
    use_backend core-cw-home if { path_beg /hcl/wizard/ OR path /hcl/wizard }
    use_backend core-dxconnect if { path_beg /hcl/dxconnect/processHandler }
    {{- end }}

    default_backend core-dx-home
{{- end }}

  # Define DNS resolver for core headless services
  resolvers kube-dns
    # Use the Pod's /etc/resolv.conf file (created by Kubernetes) to define the nameserver
    parse-resolv-conf
    accepted_payload_size 8192
{{- if and (eq (include "hcl-dx-deployment.webEngineEnabled" .) "true") ( .Values.configuration.webEngine.debug) }}
  # Web Engine Debug
  frontend web-engine-debug-frontend
    mode tcp
    bind *:{{ include "hcl-dx-deployment.ports.webEngine.debug" . }}
    option tcplog
    default_backend web-engine-debug-backend

  backend web-engine-debug-backend
    mode tcp
    server-template web-engine-debug 1 {{ .Release.Name }}-web-engine.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.webEngine.debug" . }} check resolvers kube-dns init-addr none
{{- end }}
  
  backend web-engine-dx-home
    acl has_oidc_set_cookie res.hdr(Set-Cookie) -m reg ^OIDCSTATE
    acl has_saml_set_cookie res.hdr(Set-Cookie) -m reg ^WasSamlAcsID
    dynamic-cookie-key {{ .Release.Name }}
    acl path_metrics path -i /metrics
    http-request deny if path_metrics
    # Set CSP frame-ancestors if URLs are provided
{{- if (.Values.networking.webEngine.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " " .Values.networking.webEngine.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
{{- if (.Values.networking.haproxy.alwaysEnableSessionAffinity) }}
    # If alwaysEnableSessionAffinity is true, we have haproxy to insert the DxSessionAffinity cookie
    # insert will only add the cookie if a valid cookie is not present. We use insert rather than 
    # rewrite because we are not setting the cookie via Set-Cookie DxSessionAffinity=placeholder_value.
{{- if (.Values.networking.haproxy.ssl) }}
    cookie DxSessionAffinity insert indirect httponly secure dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache attr SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }}
{{- else }}
    cookie DxSessionAffinity insert indirect httponly dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache 
{{- end }}
{{- else }}
    # We use this workaround to create a second cookie when certain cookies are present
    # The new cookie will be used to handle the stickyness. This prevents the actual cookie value from being altered.
    # The cookie is created with a placeholder value and is rewritten by HAProxy
{{- if (.Values.networking.haproxy.ssl) }}
    http-response add-header Set-Cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly;\ Secure;\ SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }} if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found } || has_oidc_set_cookie || has_saml_set_cookie
{{- else }}
    http-response add-header Set-Cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found } || has_oidc_set_cookie || has_saml_set_cookie
{{- end }}
    cookie DxSessionAffinity rewrite dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache
{{- end }}
    default-server ssl check verify none
    # Setting server template "num" parameter to highest number among `maxReplica`, `replica`, and 99. `maxReplica` and `replica` would be considered from the Helm values.
    # The purpose to set the higher number of server template is to cover for auto-scaling of the core pods.
    # We do not want to set this number too high as Prometheus is scraping all servers which are specified to `server-template` whether it's assigned to any pods or not.
    server-template web-engine-dx-home {{ max .Values.scaling.horizontalPodAutoScaler.webEngine.maxReplicas .Values.scaling.replicas.webEngine 99 }} {{ .Release.Name }}-web-engine-headless.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.webEngine.dxHomeSecure" . }} check resolvers kube-dns init-addr none

  backend core-dx-home
    acl has_oidc_set_cookie res.hdr(Set-Cookie) -m reg ^OIDCSTATE
    acl has_saml_set_cookie res.hdr(Set-Cookie) -m reg ^WasSamlAcsID
    dynamic-cookie-key {{ .Release.Name }}
    # Set CSP frame-ancestors if URLs are provided
{{- if (.Values.networking.core.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " " .Values.networking.core.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
{{- if (.Values.networking.haproxy.alwaysEnableSessionAffinity) }}
    # If alwaysEnableSessionAffinity is true, we have haproxy to insert the DxSessionAffinity cookie
    # insert will only add the cookie if a valid cookie is not present. We use insert rather than 
    # rewrite because we are not setting the cookie via Set-Cookie DxSessionAffinity=placeholder_value.
{{- if (.Values.networking.haproxy.ssl) }}
    cookie DxSessionAffinity insert indirect httponly secure dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache attr SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }}
{{- else }}
    cookie DxSessionAffinity insert indirect httponly dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache 
{{- end }}
{{- else }}
    # We use this workaround to create a second cookie when certain cookies are present
    # The new cookie will be used to handle the stickyness. This prevents the actual cookie value from being altered.
    # The cookie is created with a placeholder value and is rewritten by HAProxy
{{- if (.Values.networking.haproxy.ssl) }}
    http-response add-header Set-Cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly;\ Secure;\ SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }} if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found } || has_oidc_set_cookie || has_saml_set_cookie
{{- else }}
    http-response add-header Set-Cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found } || has_oidc_set_cookie || has_saml_set_cookie
{{- end }}
    cookie DxSessionAffinity rewrite dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache
{{- end }}
    default-server ssl check verify none
    # Setting server template "num" parameter to highest number among `maxReplica`, `replica`, and 99. `maxReplica` and `replica` would be considered from the Helm values.
    # The purpose to set the higher number of server template is to cover for auto-scaling of the core pods.
    # We do not want to set this number too high as Prometheus is scraping all servers which are specified to `server-template` whether it's assigned to any pods or not.
    server-template core-dx-home {{ max .Values.scaling.horizontalPodAutoScaler.core.maxReplicas .Values.scaling.replicas.core 99 }} {{ .Release.Name }}-core-headless.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.core.dxHomeSecure" . }} check resolvers kube-dns init-addr none

{{- if (.Values.configuration.core.exposeConfigurationConsole) }}
  backend core-was-admin
    dynamic-cookie-key {{ .Release.Name }}
{{- if (.Values.networking.haproxy.alwaysEnableSessionAffinity) }}
    # If alwaysEnableSessionAffinity is true, we have haproxy to insert the DxSessionAffinity cookie
    # insert will only add the cookie if a valid cookie is not present. We use insert rather than 
    # rewrite because we are not setting the cookie via Set-Cookie DxSessionAffinity=placeholder_value.
{{- if (.Values.networking.haproxy.ssl) }}
    cookie DxSessionAffinity insert indirect httponly secure dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache attr SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }}
{{- else }}
    cookie DxSessionAffinity insert indirect httponly dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache 
{{- end }}
{{- else }}
    # We use this workaround to create a second cookie when JSESSIONID is present
    # The new cookie will be used to handle the stickyness. This prevents the actual JSESSIONID value from being altered
{{- if (.Values.networking.haproxy.ssl) }}
    http-response add-header Set-cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly;\ Secure;\ SameSite={{ .Values.networking.haproxy.affinityCookieSameSiteAttribute }} if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found }
{{- else }}
    http-response add-header Set-cookie DxSessionAffinity=placeholder_value;\ path=/;\ HttpOnly if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found }
{{- end }}
    cookie DxSessionAffinity rewrite dynamic {{ include "hcl-dx-deployment.affinityCookieDomain" . }}nocache
{{- end }}
    default-server ssl check verify none
    # Setting server template "num" parameter to highest number among `maxReplica`, `replica`, and 99. `maxReplica` and `replica` would be considered from the Helm values.
    # The purpose to set the higher number of server template is to cover for auto-scaling of the core pods.
    # We do not want to set this number too high as Prometheus is scraping all servers which are specified to `server-template` whether it's assigned to any pods or not.
    server-template core-was-admin {{ max .Values.scaling.horizontalPodAutoScaler.core.maxReplicas .Values.scaling.replicas.core 99 }} {{ .Release.Name }}-core-headless.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.core.wasAdminSecure" . }} check resolvers kube-dns init-addr none
{{- end }}

{{- if .Values.configuration.core.tuning.configWizard }}
  backend core-dxconnect
    dynamic-cookie-key {{ .Release.Name }}
    # We use this workaround to create a second cookie when CWSession4 is present
    # The new cookie will be used to handle the stickyness. This prevents the actual CWSession4 value from being altered
    http-response add-header Set-cookie CwSessionAffinity=%[res.cook(CWSession4)];\ path=/ if { res.cook(CWSession4) -m found }
    cookie CwSessionAffinity rewrite dynamic nocache
    default-server ssl check verify none
    # Setting server template "num" parameter to highest number among `maxReplica`, `replica`, and 99. `maxReplica` and `replica` would be considered from the Helm values.
    # The purpose to set the higher number of server template is to cover for auto-scaling of the core pods.
    # We do not want to set this number too high as Prometheus is scraping all servers which are specified to `server-template` whether it's assigned to any pods or not.
    server-template core-dxconnect {{ max .Values.scaling.horizontalPodAutoScaler.core.maxReplicas .Values.scaling.replicas.core 99 }} {{ .Release.Name }}-core-headless.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.core.cwHomeSecure" . }} check resolvers kube-dns init-addr none

  backend core-cw-home
    default-server ssl check verify none
    # For Config Wizard we always connect to the first Core Pod (core-0). Requests will be forwarded even when the Pod is unready to allow Config Wizard to keep communicating during restarts.
    server-template core-cw-home 1 {{ .Release.Name }}-core-unready-pod-0.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.core.cwHomeSecure" . }} check resolvers kube-dns init-addr none

  frontend cw-admin-sec
    mode tcp
    option tcplog
    # Default tcp log format with IP removed
    log-format "[%t] %ft %b/%s %Tw/%Tc/%Tt %B %ts %ac/%fc/%bc/%sc/%rc %sq/%bq"
    bind :{{ include "hcl-dx-deployment.ports.core.cwAdminSec" . }} {{- if (and .Values.networking.haproxy.ssl (ne (include "hcl-dx-deployment.isSofyDeployment" .) "true")) }} ssl crt /etc/ssl/certs/tls.crt {{ end }}
    default_backend cw-admin-sec

  backend cw-admin-sec
    dynamic-cookie-key {{ .Release.Name }}
    # We use this workaround to create a second cookie when JSESSIONID is present
    # The new cookie will be used to handle the stickyness. This prevents the actual JSESSIONID value from being altered
    http-response add-header Set-cookie CwAdminSessionAffinity=%[res.cook({{ .Values.networking.haproxy.sessionCookieName }})];\ path=/ if { res.cook({{ .Values.networking.haproxy.sessionCookieName }}) -m found }
    cookie CwAdminSessionAffinity rewrite dynamic nocache
    default-server ssl check verify none
    # Setting server template "num" parameter to highest number among `maxReplica`, `replica`, and 99. `maxReplica` and `replica` would be considered from the Helm values.
    # The purpose to set the higher number of server template is to cover for auto-scaling of the core pods.
    # We do not want to set this number too high as Prometheus is scraping all servers which are specified to `server-template` whether it's assigned to any pods or not.
    server-template cw-admin-sec {{ max .Values.scaling.horizontalPodAutoScaler.core.maxReplicas .Values.scaling.replicas.core 99 }} {{ .Release.Name }}-core-headless.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.core.cwAdminSec" . }} check resolvers kube-dns init-addr none
{{- end }}

{{- if (.Values.configuration.remoteSearch.exposeConfigurationConsole) }}
  frontend remote-search-frontend
    mode tcp
    option tcplog
    # Default tcp log format with IP removed
    log-format "[%t] %ft %b/%s %Tw/%Tc/%Tt %B %ts %ac/%fc/%bc/%sc/%rc %sq/%bq"
    bind :{{ include "hcl-dx-deployment.ports.remoteSearch.wasAdminSecure" . }} {{- if (and .Values.networking.haproxy.ssl (ne (include "hcl-dx-deployment.isSofyDeployment" .) "true")) }} ssl crt /etc/ssl/certs/tls.crt {{ end }}
    default_backend remote-search

  backend remote-search
    server-template remote-search 1 {{ .Release.Name }}-remote-search.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.remoteSearch.wasAdminSecure" . }} ssl check verify none resolvers kube-dns init-addr none
{{- end }}

  defaults
    timeout connect 10s
    timeout client 1200s
    timeout server 1200s
    log global
    mode http
    option httplog
  backend dam
{{- if (.Values.networking.addon.digitalAssetManagement.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " "  .Values.networking.addon.digitalAssetManagement.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
    server-template dam 1 {{ .Release.Name }}-digital-asset-management.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none

  backend content
{{- if (.Values.networking.addon.contentComposer.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " "  .Values.networking.addon.contentComposer.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
    server-template content 1 {{ .Release.Name }}-content-composer.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none

  backend image-processor
{{- if (.Values.networking.addon.imageProcessor.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " "  .Values.networking.addon.imageProcessor.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
    server-template image-processor 1 {{ .Release.Name }}-image-processor.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none

  backend runtime-controller
    server-template runtime-controller 1 {{ .Release.Name }}-runtime-controller.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none

  backend ring-api
{{- if (.Values.networking.addon.ringApi.cspFrameAncestorsEnabled) }}
    http-response add-header Content-Security-Policy "frame-ancestors 'self' {{ join " "  .Values.networking.addon.ringApi.cspFrameAncestorsAllowedSourceURLs }}"
{{- end }}
    server-template ring-api 1 {{ .Release.Name }}-ring-api.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none

{{- if (.Values.networking.searchMiddlewareService) }}
  backend search-middleware-service
    server-template search-middleware-service 1 {{ .Values.networking.searchMiddlewareService }}.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none
{{- end -}}

{{- if (.Values.incubator.networking.dxIqService) }}
  backend dx-ai-integrator-service
    server-template dx-ai-integrator-service 1 {{ .Values.incubator.networking.dxIqService }}.{{ .Release.Namespace }}.svc.cluster.local:{{ include "hcl-dx-deployment.ports.global.nodeApplication" . }} check resolvers kube-dns init-addr none
{{- end -}}

{{- if .Values.peopleservice.enabled }}

  backend people-service-ui
     server-template people-server-ui {{ .Values.peopleservice.scaling.replicaCount }} {{ .Release.Name }}-peopleservice.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.peopleservice.service.ports.http }} check resolvers kube-dns init-addr none

  backend people-service-api
    server-template people-server-api {{ .Values.peopleservice.scaling.replicaCount }} {{ .Release.Name }}-peopleservice.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.peopleservice.service.ports.http }} check resolvers kube-dns init-addr none 
{{- end }}

{{/* This end-statement must be the last line as it belongs to the very first define-statement */}}
{{- end -}}
