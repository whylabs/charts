{{/*
Expand the name of the chart.
*/}}
{{- define "guardrails.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "guardrails.fullname" -}}
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
{{- define "guardrails.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guardrails.labels" -}}
helm.sh/chart: {{ include "guardrails.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{ include "guardrails.selectorLabels" . }}
{{- end }}

{{/*
Cache labels
*/}}
{{- define "guardrails.cacheLabels" -}}
helm.sh/chart: {{ include "guardrails.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{ include "guardrails.cacheSelectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guardrails.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guardrails.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Cache Selector labels
*/}}
{{- define "guardrails.cacheSelectorLabels" -}}
app.kubernetes.io/name: {{ include "guardrails.name" . }}-nginx
app.kubernetes.io/instance: {{ .Release.Name }}-nginx
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "guardrails.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guardrails.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
