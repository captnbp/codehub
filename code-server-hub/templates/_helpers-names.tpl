{{- /*
    These helpers encapsulates logic on how we name resources. They also enable
    parent charts to reference these dynamic resource names.

    To avoid duplicating documentation, for more information, please see the the
    fullnameOverride entry in schema.yaml or the configuration reference that
    schema.yaml renders to.

    https://z2jh.jupyter.org/en/latest/resources/reference.html#fullnameOverride
*/}}



{{- /*
    Utility templates
*/}}


{{/*
Expand the name of the chart.
*/}}
{{- define "jupyterhub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jupyterhub.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jupyterhub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
    Renders to a blank string or if the fullname template is truthy renders to it
    with an appended dash.
*/}}
{{- define "jupyterhub.fullname.dash" -}}
    {{- if (include "jupyterhub.fullname" .) }}
        {{- include "jupyterhub.fullname" . }}-
    {{- end }}
{{- end }}



{{- /*
    Namespaced resources
*/}}

{{- /* hub Deployment */}}
{{- define "jupyterhub.hub.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}hub
{{- end }}

{{- /* hub-existing-secret Secret */}}
{{- define "jupyterhub.hub-existing-secret.fullname" -}}
    {{- /* A hack to avoid issues from invoking this from a parent Helm chart. */}}
    {{- $existing_secret := .Values.hub.existingSecret }}
    {{- if ne .Chart.Name "code-server-hub" }}
        {{- $existing_secret = .Values.jupyterhub.hub.existingSecret }}
    {{- end }}
    {{- if $existing_secret }}
        {{- $existing_secret }}
    {{- end }}
{{- end }}

{{- /* hub-existing-secret-or-default Secret */}}
{{- define "jupyterhub.hub-existing-secret-or-default.fullname" -}}
    {{- include "jupyterhub.hub-existing-secret.fullname" . | default (include "jupyterhub.hub.fullname" .) }}
{{- end }}

{{- /* hub PVC */}}
{{- define "jupyterhub.hub-pvc.fullname" -}}
    {{- include "jupyterhub.hub.fullname" . }}-db-dir
{{- end }}

{{- /* proxy Deployment */}}
{{- define "jupyterhub.proxy.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}proxy
{{- end }}

{{- /* proxy-api Service */}}
{{- define "jupyterhub.proxy-api.fullname" -}}
    {{- include "jupyterhub.proxy.fullname" . }}-api
{{- end }}

{{- /* proxy-http Service */}}
{{- define "jupyterhub.proxy-http.fullname" -}}
    {{- include "jupyterhub.proxy.fullname" . }}-http
{{- end }}

{{- /* proxy-public Service */}}
{{- define "jupyterhub.proxy-public.fullname" -}}
    {{- include "jupyterhub.proxy.fullname" . }}-public
{{- end }}

{{- /* proxy-public-tls Secret */}}
{{- define "jupyterhub.proxy-public-tls.fullname" -}}
    {{- include "jupyterhub.proxy-public.fullname" . }}-tls-acme
{{- end }}

{{- /* proxy-public-manual-tls Secret */}}
{{- define "jupyterhub.proxy-public-manual-tls.fullname" -}}
    {{- include "jupyterhub.proxy-public.fullname" . }}-manual-tls
{{- end }}

{{- /* autohttps Deployment */}}
{{- define "jupyterhub.autohttps.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}autohttps
{{- end }}

{{- /* user-scheduler Deployment */}}
{{- define "jupyterhub.user-scheduler-deploy.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}user-scheduler
{{- end }}

{{- /* user-scheduler leader election lock resource */}}
{{- define "jupyterhub.user-scheduler-lock.fullname" -}}
    {{- include "jupyterhub.user-scheduler-deploy.fullname" . }}-lock
{{- end }}

{{- /* user-placeholder StatefulSet */}}
{{- define "jupyterhub.user-placeholder.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}user-placeholder
{{- end }}

{{- /* image-awaiter Job */}}
{{- define "jupyterhub.hook-image-awaiter.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}hook-image-awaiter
{{- end }}

{{- /* hook-image-puller DaemonSet */}}
{{- define "jupyterhub.hook-image-puller.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}hook-image-puller
{{- end }}

{{- /* continuous-image-puller DaemonSet */}}
{{- define "jupyterhub.continuous-image-puller.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}continuous-image-puller
{{- end }}

{{- /* singleuser NetworkPolicy */}}
{{- define "jupyterhub.singleuser.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}singleuser
{{- end }}

{{- /* image-pull-secret Secret */}}
{{- define "jupyterhub.image-pull-secret.fullname" -}}
    {{- include "jupyterhub.fullname.dash" . }}image-pull-secret
{{- end }}

{{- /* Ingress */}}
{{- define "jupyterhub.ingress.fullname" -}}
    {{- if (include "jupyterhub.fullname.dash" .) }}
        {{- include "jupyterhub.fullname.dash" . }}
    {{- else -}}
        jupyterhub
    {{- end }}
{{- end }}



{{- /*
    Cluster wide resources

    We enforce uniqueness of names for our cluster wide resources. We assume that
    the prefix from setting fullnameOverride to null or a string will be cluster
    unique.
*/}}

{{- /* Priority */}}
{{- define "jupyterhub.priority.fullname" -}}
    {{- if (include "jupyterhub.fullname.dash" .) }}
        {{- include "jupyterhub.fullname.dash" . }}
    {{- else }}
        {{- .Release.Name }}-default-priority
    {{- end }}
{{- end }}

{{- /* user-placeholder Priority */}}
{{- define "jupyterhub.user-placeholder-priority.fullname" -}}
    {{- if (include "jupyterhub.fullname.dash" .) }}
        {{- include "jupyterhub.user-placeholder.fullname" . }}
    {{- else }}
        {{- .Release.Name }}-user-placeholder-priority
    {{- end }}
{{- end }}

{{- /* user-scheduler's registered name */}}
{{- define "jupyterhub.user-scheduler.fullname" -}}
    {{- if (include "jupyterhub.fullname.dash" .) }}
        {{- include "jupyterhub.user-scheduler-deploy.fullname" . }}
    {{- else }}
        {{- .Release.Name }}-user-scheduler
    {{- end }}
{{- end }}



{{- /*
    A template to render all the named templates in this file for use in the
    hub's ConfigMap.

    It is important we keep this in sync with the available templates.
*/}}
{{- define "jupyterhub.name-templates" -}}
fullname: {{ include "jupyterhub.fullname" . | quote }}
fullname-dash: {{ include "jupyterhub.fullname.dash" . | quote }}
hub: {{ include "jupyterhub.hub.fullname" . | quote }}
hub-existing-secret: {{ include "jupyterhub.hub-existing-secret.fullname" . | quote }}
hub-existing-secret-or-default: {{ include "jupyterhub.hub-existing-secret-or-default.fullname" . | quote }}
hub-pvc: {{ include "jupyterhub.hub-pvc.fullname" . | quote }}
proxy: {{ include "jupyterhub.proxy.fullname" . | quote }}
proxy-api: {{ include "jupyterhub.proxy-api.fullname" . | quote }}
proxy-http: {{ include "jupyterhub.proxy-http.fullname" . | quote }}
proxy-public: {{ include "jupyterhub.proxy-public.fullname" . | quote }}
proxy-public-tls: {{ include "jupyterhub.proxy-public-tls.fullname" . | quote }}
proxy-public-manual-tls: {{ include "jupyterhub.proxy-public-manual-tls.fullname" . | quote }}
autohttps: {{ include "jupyterhub.autohttps.fullname" . | quote }}
user-scheduler-deploy: {{ include "jupyterhub.user-scheduler-deploy.fullname" . | quote }}
user-scheduler-lock: {{ include "jupyterhub.user-scheduler-lock.fullname" . | quote }}
user-placeholder: {{ include "jupyterhub.user-placeholder.fullname" . | quote }}
hook-image-awaiter: {{ include "jupyterhub.hook-image-awaiter.fullname" . | quote }}
hook-image-puller: {{ include "jupyterhub.hook-image-puller.fullname" . | quote }}
continuous-image-puller: {{ include "jupyterhub.continuous-image-puller.fullname" . | quote }}
singleuser: {{ include "jupyterhub.singleuser.fullname" . | quote }}
image-pull-secret: {{ include "jupyterhub.image-pull-secret.fullname" . | quote }}
ingress: {{ include "jupyterhub.ingress.fullname" . | quote }}
priority: {{ include "jupyterhub.priority.fullname" . | quote }}
user-placeholder-priority: {{ include "jupyterhub.user-placeholder-priority.fullname" . | quote }}
user-scheduler: {{ include "jupyterhub.user-scheduler.fullname" . | quote }}
{{- end }}
