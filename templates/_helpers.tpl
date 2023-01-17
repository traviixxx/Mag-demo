{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "magnolia.name" -}}
{{- default $.Chart.Name $.Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "magnolia.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "magnolia.chart" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "magnolia.labels" -}}
app: {{ template "magnolia.fullname" . }}
chart: {{ template "magnolia.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}

{{/*
Port list for the magnolia service. Takes the redirect server into consideration.
*/}}
{{- define "magnolia.ports" -}}
{{- $dollar := index . 0 }}
{{- $magnoliaMode := index . 1 }}
{{- if and (eq $magnoliaMode "public") ($dollar.Values.magnoliaPublic.redirects.enabled) }}
{{- range $key, $value := $dollar.Values.service.ports }}
{{- if eq $value.name "http" -}}
- name: http
  port: {{ $value.port }}
  protocol: {{ $value.protocol }}
  targetPort: {{ $dollar.Values.service.redirectPort }}
{{ else -}}
- {{ toYaml $value | nindent 2 | trimPrefix "\n  " }}
{{- end }}
{{- end }}
{{- else }}
{{- toYaml $dollar.Values.service.ports }}
{{- end }}
{{- end -}}