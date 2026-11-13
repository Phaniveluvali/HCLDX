#********************************************************************
#* Licensed Materials - Property of HCL                             *
#*                                                                  *
#* Copyright HCL Technologies Ltd. 2024, 2025. All Rights Reserved. *
#*                                                                  *
#* Note to US Government Users Restricted Rights:                   *
#*                                                                  *
#* Use, duplication or disclosure restricted by GSA ADP Schedule    *
#********************************************************************

{{- define "hcl-dx-deployment.ldapConfig" -}}
<server description="WebEngineServer">
  <ldapRegistry id="ldap" realm="SampleLdapIDSRealm"
    host='{{ include "hcl-dx-deployment.ldapWebEngineConfigurationHost" . }}'
    port='{{ include "hcl-dx-deployment.ldapWebEngineConfigurationPort" . }}' ignoreCase="true"
    baseDN='{{ include "hcl-dx-deployment.ldapWebEngineConfigurationSuffix" . }}'
    ldapType='{{ .Values.configuration.webEngine.ldap.serverType }}'
    sslEnabled='{{ include "hcl-dx-deployment.ldapWebEngineSSLEnabled" . }}'
    bindDN='${LDAP_BIND_USER}'
    bindPassword='${LDAP_BIND_PASSWORD}'>
    <customFilters
      userFilter="(&amp;(uid=%v)(objectclass=inetOrgPerson))"
      groupFilter="(&amp;(cn=%v)(objectclass=groupOfUniqueNames))"
      userIdMap="*:uid"
      groupIdMap="*:cn"
      groupMemberIdMap="groupOfUniqueNames:uniqueMember">
    </customFilters>
    <ldapCache>
      <attributesCache size="4000" sizeLimit="4000" timeout="2400s" />
      <searchResultsCache resultsSizeLimit="4000" size="4000" timeout="2400s" />
    </ldapCache>
    <contextPool preferredSize="20"/>
    <attributeConfiguration>
      <attribute name="mail" propertyName="ibm-primaryEmail" entityType="PersonAccount"/>
      <attribute name="title" propertyName="ibm-jobTitle" entityType="PersonAccount"/>
    </attributeConfiguration>
  </ldapRegistry>
  <federatedRepository>
    <primaryRealm name="FederatedRealm" allowOpIfRepoDown="true">
      <participatingBaseEntry name="o=defaultWIMFileBasedRealm"/>
      <participatingBaseEntry name='{{ include "hcl-dx-deployment.ldapWebEngineConfigurationSuffix" . }}' />
    </primaryRealm>
  </federatedRepository>
</server>
{{- end }}
