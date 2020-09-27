{{/* vim: set filetype=mustache: */}}
{{- /*
  ## About
  This file contains helpers to systematically name, label and select Kubernetes
  objects we define in the .yaml template files.


  ## How helpers work
  Helm helper functions is a good way to avoid repeating something. They will
  generate some output based on one single dictionary of input that we call the
  helpers scope. When you are in helm, you access your current scope with a
  single a single punctuation (.).

  When you ask a helper to render its content, one often forward the current
  scope to the helper in order to allow it to access .Release.Name,
  .Values.rbac.enabled and similar values.

  #### Example - Passing the current scope
  {{ include "jupyterhub.commonLabels" . }}

  It would be possible to pass something specific instead of the current scope
  (.), but that would make .Release.Name etc. inaccessible by the helper which
  is something we aim to avoid.

  #### Example - Passing a new scope
  {{ include "demo.bananaPancakes" (dict "pancakes" 5 "bananas" 3) }}

  To let a helper access the current scope along with additional values we have
  opted to create dictionary containing additional values that is then populated
  with additional values from the current scope through a the merge function.

  #### Example - Passing a new scope augmented with the old
  {{- $_ := merge (dict "appLabel" "kube-lego") . }}
  {{- include "jupyterhub.matchLabels" $_ | nindent 6 }}

  In this way, the code within the definition of `jupyterhub.matchLabels` will
  be able to access .Release.Name and .appLabel.

  NOTE:
    The ordering of merge is crucial, the latter argument is merged into the
    former. So if you would swap the order you would influence the current scope
    risking unintentional behavior. Therefore, always put the fresh unreferenced
    dictionary (dict "key1" "value1") first and the current scope (.) last.


  ## Declared helpers
  - appLabel          |
  - componentLabel    |
  - nameField         | uses componentLabel
  - commonLabels      | uses appLabel
  - labels            | uses commonLabels
  - matchLabels       | uses labels
  - podCullerSelector | uses matchLabels

  NOTE:
    The "jupyterhub.matchLabels" and "jupyterhub.labels" is passed an augmented
    scope that will influence the helpers' behavior. It get the current scope
    "." but merged with a dictionary containing extra key/value pairs. In this
    case the "." scope was merged with a small dictionary containing only one
    key/value pair "appLabel: kube-lego". It is required for kube-lego to
    function properly. It is a way to override the default app label's value.
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
  jupyterhub.appLabel:
    Used by "jupyterhub.labels".
*/}}
{{- define "jupyterhub.appLabel" -}}
{{ .Values.nameOverride | default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- /*
  jupyterhub.componentLabel:
    Used by "jupyterhub.labels" and "jupyterhub.nameField".

    NOTE: The component label is determined by either...
    - 1: The provided scope's .componentLabel
    - 2: The template's filename if living in the root folder
    - 3: The template parent folder's name
    -  : ...and is combined with .componentPrefix and .componentSuffix
*/}}
{{- define "jupyterhub.componentLabel" -}}
{{- $file := .Template.Name | base | trimSuffix ".yaml" -}}
{{- $parent := .Template.Name | dir | base | trimPrefix "templates" -}}
{{- $component := .componentLabel | default $parent | default $file -}}
{{- $component := print (.componentPrefix | default "") $component (.componentSuffix | default "") -}}
{{ $component }}
{{- end }}


{{- /*
  jupyterhub.nameField:
    Populates the name field's value.
    NOTE: some name fields are limited to 63 characters by the DNS naming spec.

  TODO:
  - [ ] Set all name fields using this helper.
  - [ ] Optionally prefix the release name based on some setting in
        .Values to allow for multiple deployments within a single namespace.
*/}}
{{- define "jupyterhub.nameField" -}}
{{- $name := print (.namePrefix | default "") (include "jupyterhub.componentLabel" .) (.nameSuffix | default "") -}}
{{ printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- /*
  jupyterhub.commonLabels:
    Foundation for "jupyterhub.labels".
    Provides labels: app, release, (chart and heritage).
*/}}
{{- define "jupyterhub.commonLabels" -}}
app.kubernetes.io/name: {{ .appLabel | default (include "jupyterhub.appLabel" .) }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if not .matchLabels }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- end }}


{{- /*
  jupyterhub.labels:
    Provides labels: component, app, release, (chart and heritage).
*/}}
{{- define "jupyterhub.labels" -}}
app.kubernetes.io/component: {{ include "jupyterhub.componentLabel" . }}
{{ include "jupyterhub.commonLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}


{{- /*
  jupyterhub.matchLabels:
    Used to provide pod selection labels: component, app, release.
*/}}
{{- define "jupyterhub.matchLabels" -}}
{{- $_ := merge (dict "matchLabels" true) . -}}
{{ include "jupyterhub.labels" $_ }}
{{- end }}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "jupyterhub.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
  jupyterhub.resources:
    The resource request of a singleuser.
*/}}
{{- define "jupyterhub.resources" -}}
{{- $r1 := .Values.singleuser.cpu.guarantee -}}
{{- $r2 := .Values.singleuser.memory.guarantee -}}
{{- $r3 := .Values.singleuser.extraResource.guarantees -}}
{{- $r := or $r1 $r2 $r3 -}}
{{- $l1 := .Values.singleuser.cpu.limit -}}
{{- $l2 := .Values.singleuser.memory.limit -}}
{{- $l3 := .Values.singleuser.extraResource.limits -}}
{{- $l := or $l1 $l2 $l3 -}}
{{- if $r -}}
requests:
  {{- if $r1 }}
  cpu: {{ .Values.singleuser.cpu.guarantee }}
  {{- end }}
  {{- if $r2 }}
  memory: {{ .Values.singleuser.memory.guarantee }}
  {{- end }}
  {{- if $r3 }}
  {{- range $key, $value := .Values.singleuser.extraResource.guarantees }}
  {{ $key | quote }}: {{ $value | quote }}
  {{- end }}
  {{- end }}
{{- end }}

{{- if $l }}
limits:
  {{- if $l1 }}
  cpu: {{ .Values.singleuser.cpu.limit }}
  {{- end }}
  {{- if $l2 }}
  memory: {{ .Values.singleuser.memory.limit }}
  {{- end }}
  {{- if $l3 }}
  {{- range $key, $value := .Values.singleuser.extraResource.limits }}
  {{ $key | quote }}: {{ $value | quote }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Renders a value that contains template.
Usage:
{{ include "jupyterhub.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "jupyterhub.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
 Create the name of the master service account to use
 */}}
{{- define "jupyterhub.singleuser.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ $serviceAccountName := default (include "jupyterhub.fullname" .) .Values.singleuser.serviceAccount }}
    {{- printf "%s-singleuser" $serviceAccountName }}
{{- else -}}
    {{ default "default" .Values.singleuser.serviceAccount }}
{{- end -}}
{{- end -}}