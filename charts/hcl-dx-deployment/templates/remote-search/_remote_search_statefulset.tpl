{{/*
********************************************************************
* Licensed Materials - Property of HCL                             *
*                                                                  *
* Copyright HCL Technologies Ltd. 2021. All Rights Reserved.       *
*                                                                  *
* Note to US Government Users Restricted Rights:                   *
*                                                                  *
* Use, duplication or disclosure restricted by GSA ADP Schedule    *
********************************************************************
*/}}

{{/*
  This file contains additional logic for the statefulSet of Remote Search
*/}}

{{/*
  The following definitions are part of the start commands
*/}}
{{- define "hcl-dx-deployment.remoteSearch.setIndexRoot" -}}
  {{- printf "export SERVERINDEXROOT='/opt/HCL/AppServer/profiles/prs_profile/config/cells/'" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.setOrgHost" -}}
  {{- printf "export ORGHOST=$(grep hostName $SERVERINDEX | awk '{print $6}' | cut -d'\\\"' -f2)" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.setFind" -}}
  {{- printf "FIND='/usr/bin/find'" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.setServerIndex" -}}
  {{- printf "export SERVERINDEX=$($FIND $SERVERINDEXROOT -type f -name serverindex.xml -print)" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.statusMessage" -}}
  {{- printf "echo 'Changing hostname in ' $SERVERINDEX 'from '  $ORGHOST 'to' $TARGETHOST" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.hostUpdate" -}}
  {{- printf "sed -i s/host=\\\"$ORGHOST\\\"/host=\\\"$TARGETHOST\\\"/ $SERVERINDEX" -}}
{{- end -}}

{{- define "hcl-dx-deployment.remoteSearch.origCommand" -}}
  {{- printf "sed -i '/host:VirtualHost>/i <aliases xmi:id=\\\"HostAlias_15179\\\" hostname=\\\"*\\\" port=\\\"443\\\"/>' /opt/HCL/AppServer/profiles/prs_profile/config/cells/*/virtualhosts.xml; sed -i '/<services xmi:type=\\\"applicationserver.webcontainer/i  <properties xmi:id=\\\"Property_1567528967018\\\" name=\\\"trusthostheaderport\\\" value=\\\"true\\\" required=\\\"false\\\"/>' /opt/HCL/AppServer/profiles/prs_profile/config/cells/*/nodes/*/servers/server1/server.xml; sed  -i '/<services xmi:type=\\\"applicationserver.webcontainer/i  <properties xmi:id=\\\"Property_1567528989452\\\" name=\\\"com.ibm.ws.webcontainer.extractHostHeaderPort\\\" value=\\\"true\\\" required=\\\"false\\\"/>' /opt/HCL/AppServer/profiles/prs_profile/config/cells/*/nodes/*/servers/server1/server.xml; /opt/HCL/AppServer/profiles/prs_profile/bin/startServer.sh server1; tail -f /opt/HCL/AppServer/profiles/prs_profile/logs/server1/SystemOut.log" -}}
{{- end -}}


{{/*
  The complete remote search start command
  This must move to a proper entrypoint scripting in the future
*/}}
{{- define "hcl-dx-deployment.remoteSearchStartCommand" -}}
  {{- printf "/home/dx_user/checkVerifyPrsProfile.sh;%s;export TARGETHOST='%s-remote-search';%s;%s;%s;%s;%s;%s" (include "hcl-dx-deployment.remoteSearch.setIndexRoot" .) .Release.Name (include "hcl-dx-deployment.remoteSearch.setFind" .) (include "hcl-dx-deployment.remoteSearch.setServerIndex" .) (include "hcl-dx-deployment.remoteSearch.setOrgHost" .) (include "hcl-dx-deployment.remoteSearch.statusMessage" .) (include "hcl-dx-deployment.remoteSearch.hostUpdate" .) (include "hcl-dx-deployment.remoteSearch.origCommand" .) -}}
{{- end -}}
