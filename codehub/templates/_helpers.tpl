{{/*
Copyright VMware, Inc.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- /*
    Returns given number of random Hex characters.

    - randNumeric 4 | atoi generates a random number in [0, 10^4)
      This is a range range evenly divisble by 16, but even if off by one,
      that last partial interval offsetting randomness is only 1 part in 625.
    - mod N 16 maps to the range 0-15
    - printf "%x" represents a single number 0-15 as a single hex character
*/}}
{{- define "codehub.randHex" -}}
    {{- $result := "" }}
    {{- range $i := until . }}
        {{- $rand_hex_char := mod (randNumeric 4 | atoi) 16 | printf "%x" }}
        {{- $result = print $result $rand_hex_char }}
    {{- end }}
    {{- $result }}
{{- end }}

{{/*
Return the proper hub image name
*/}}
{{- define "codehub.hub.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.hub.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper hub image name
*/}}
{{- define "codehub.hub.name" -}}
{{- printf "%s-hub" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the apiToken value
*/}}
{{- define "codehub.hub.config.apiToken" -}}
    {{ $hubConfiguration := include "common.tplvalues.render" ( dict "value" .Values.hub.configuration "context" $ ) | fromYaml }}
    {{- if ($hubConfiguration | dig "hub" "config" "JupyterHub" "apiToken" "") }}
        {{- $hubConfiguration.apiToken }}
    {{- else if ($hubConfiguration | dig "hub" "apiToken" "") }}
        {{- $hubConfiguration.hub.apiToken }}
    {{- else }}
        {{- $secretData := (lookup "v1" "Secret" $.Release.Namespace ( include "codehub.hub.name" . )).data }}
        {{- if hasKey $secretData "apiToken" }}
            {{- index $secretData "apiToken" | b64dec }}
        {{- else }}
            {{- include "codehub.randHex" 64 }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Return the cookie_secret value
*/}}
{{- define "codehub.hub.config.JupyterHub.cookie_secret" -}}
    {{ $hubConfiguration := include "common.tplvalues.render" ( dict "value" .Values.hub.configuration "context" $ ) | fromYaml }}
    {{- if ($hubConfiguration | dig "hub" "config" "JupyterHub" "cookie_secret" "") }}
        {{- $hubConfiguration.hub.config.JupyterHub.cookie_secret }}
    {{- else if ($hubConfiguration | dig "hub" "cookieSecret" "") }}
        {{- $hubConfiguration.hub.cookieSecret }}
    {{- else }}
        {{- $secretData := (lookup "v1" "Secret" $.Release.Namespace ( include "codehub.hub.name" . )).data }}
        {{- if hasKey $secretData "hub.config.JupyterHub.cookie_secret" }}
            {{- index $secretData "hub.config.JupyterHub.cookie_secret" | b64dec }}
        {{- else }}
            {{- include "codehub.randHex" 64 }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Return the CryptKeeper value
*/}}
{{- define "codehub.hub.config.CryptKeeper.keys" -}}
    {{ $hubConfiguration := include "common.tplvalues.render" ( dict "value" .Values.hub.configuration "context" $ ) | fromYaml }}
    {{- if ($hubConfiguration | dig "hub" "config" "CryptKeeper" "keys" "") }}
        {{- $hubConfiguration.hub.config.CryptKeeper.keys | join ";" }}
    {{- else }}
        {{- $secretData := (lookup "v1" "Secret" $.Release.Namespace ( include "codehub.hub.name" . )).data }}
        {{- if hasKey $secretData "hub.config.CryptKeeper.keys" }}
            {{- index $secretData "hub.config.CryptKeeper.keys" | b64dec }}
        {{- else }}
            {{- include "codehub.randHex" 64 }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Return the API token for a hub service
Usage:
{{ include "codehub.hub.services.get_api_token" ( dict "serviceKey" "my-service" "context" $) }}
*/}}
{{- define "codehub.hub.services.get_api_token" -}}
    {{- $services := .context.Values.hub.services }}
    {{- $explicitly_set_api_token := or (dig .serviceKey "api_token" "" $services) (dig .serviceKey "apiToken" "" $services) }}
    {{- if $explicitly_set_api_token }}
        {{- $explicitly_set_api_token }}
    {{- else }}
        {{- $k8s_state := lookup "v1" "Secret" .context.Release.Namespace (include "codehub.hub.name" .context) | default (dict "data" (dict)) }}
        {{- $k8s_secret_key := printf "hub.services.%s.apiToken" .serviceKey }}
        {{- if hasKey $k8s_state.data $k8s_secret_key }}
            {{- index $k8s_state.data $k8s_secret_key | b64dec }}
        {{- else }}
            {{- include "codehub.randHex" 64 }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Return the proper hub image name
*/}}
{{- define "codehub.proxy.name" -}}
{{- printf "%s-proxy" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper singleuser image name (to be set in the hub.configuration part). We cannot use common.images.image because of the tag
{{ include "codehub.hubconfiguration.imageEntry" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "codehub.hubconfiguration.imageEntry" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- else -}}
{{- printf "%s" $repositoryName -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper hub image name
*/}}
{{- define "codehub.proxy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.proxy.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper hub image name
*/}}
{{- define "codehub.auxiliary.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.auxiliaryImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "codehub.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.hub.image .Values.proxy.image .Values.auxiliaryImage) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
{{ include "codehub.imagePullSecretsList" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "codehub.imagePullSecretsList" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
    {{- range $pullSecrets }}
  - {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names list
*/}}
{{- define "codehub.imagePullSecrets.list" -}}
{{- include "codehub.imagePullSecretsList" (dict "images" (list .Values.hub.image .Values.proxy.image .Values.auxiliaryImage) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "codehub.imagePullerServiceAccountName" -}}
{{- if .Values.hub.serviceAccount.create -}}
    {{ default (printf "%s-image-puller" (include "common.names.fullname" .)) .Values.imagePuller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.imagePuller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "codehub.hubServiceAccountName" -}}
{{- if .Values.hub.serviceAccount.create -}}
    {{ default (printf "%s-hub" (include "common.names.fullname" .)) .Values.hub.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.hub.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "codehub.proxyServiceAccountName" -}}
{{- if .Values.proxy.serviceAccount.create -}}
    {{ default (printf "%s-proxy" (include "common.names.fullname" .)) .Values.proxy.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.proxy.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "codehub.singleuserServiceAccountName" -}}
{{- if .Values.singleuser.serviceAccount.create -}}
    {{ default (printf "%s-singleuser" (include "common.names.fullname" .)) .Values.singleuser.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.singleuser.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return  the proper Storage Class (adapted to the Jupyterhub configuration format)
{{ include "codehub.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "codehub.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClass: \"\"" -}}
  {{- else }}
      {{- printf "storageClass: %s" $storageClass -}}
  {{- end -}}
{{- end -}}

{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "codehub.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Get the Postgresql credentials secret.
*/}}
{{- define "codehub.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- if .Values.global.postgresql.auth.existingSecret }}
                {{- tpl .Values.global.postgresql.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "codehub.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "codehub.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "codehub.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-externaldb" .Release.Name) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "codehub.databaseSecretKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- else -}}
            {{- print "db-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "db-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get the Postgresql credentials secret.
*/}}
{{- define "codehub.hubSecretName" -}}
{{- if .Values.hub.existingSecret -}}
    {{- .Values.hub.existingSecret -}}
{{- else }}
    {{- printf "%s-hub" (include "common.names.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
Get the Postgresql credentials secret.
*/}}
{{- define "codehub.hubConfigmapName" -}}
{{- if .Values.hub.existingConfigmap -}}
    {{- .Values.hub.existingConfigmap -}}
{{- else }}
    {{- printf "%s-hub" (include "common.names.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
 We need to replace the Kubernetes memory/cpu terminology (e.g. 10Gi, 10Mi) with one compatible with Python (10G, 10M)
*/}}
{{- define "codehub.singleuser.resources" -}}
{{ $resources := (dict "limits" (dict) "requests" (dict)) }}
{{- if .Values.singleuser.resources -}}
    {{ $resources = .Values.singleuser.resources -}}
{{- else if ne .Values.singleuser.resourcesPreset "none" -}}
    {{ $resources = include "common.resources.preset" (dict "type" .Values.singleuser.resourcesPreset) -}}
{{- end -}}
cpu:
  limit: {{ regexReplaceAll "([A-Za-z])i" (default "" $resources.limits.cpu)  "${1}" }}
  guarantee: {{ regexReplaceAll "([A-Za-z])i" (default "" $resources.requests.cpu) "${1}" }}
memory:
  limit: {{ regexReplaceAll "([A-Za-z])i" (default "" $resources.limits.memory) "${1}" }}
  guarantee: {{ regexReplaceAll "([A-Za-z])i" (default "" $resources.requests.memory) "${1}" }}
{{- end -}}

{{/* Validate values of JupyterHub - Database */}}
{{- define "codehub.validateValues.database" -}}
{{- if and .Values.postgresql.enabled .Values.externalDatabase.host -}}
jupyherhub: Database
    You can only use one database.
    Please choose installing a PostgreSQL chart (--set postgresql.enabled=true) or
    using an external database (--set externalDatabase.host)
{{- end -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.host) -}}
jupyherhub: NoDatabase
    You did not set any database.
    Please choose installing a PostgreSQL chart (--set postgresql.enabled=true) or
    using an external database (--set externalDatabase.host)
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "codehub.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "codehub.validateValues.database" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "codehub.proxy.createTlsSecret" -}}
{{- if and .Values.tls.autoGenerated (not .Values.proxy.tls.existingSecret) .Values.tls.enabled }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the TLS secret name
*/}}
{{- define "codehub.issuerName" -}}
{{- $issuerName := .Values.tls.issuerRef.existingIssuerName -}}
{{- if $issuerName -}}
    {{- printf "%s" (tpl $issuerName $) -}}
{{- else -}}
    {{- printf "%s-http" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}