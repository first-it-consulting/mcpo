{{/* Expand the name of the chart. */}}
{{- define "mcp-mcpo-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name. */}}
{{- define "mcp-mcpo-helm.fullname" -}}
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

{{/* Create chart name and version as used by the chart label. */}}
{{- define "mcp-mcpo-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "mcp-mcpo-helm.labels" -}}
helm.sh/chart: {{ include "mcp-mcpo-helm.chart" . }}
{{ include "mcp-mcpo-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "mcp-mcpo-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-mcpo-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Create the name of the service account to use */}}
{{- define "mcp-mcpo-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mcp-mcpo-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Render a structure as YAML with template interpolation */}}
{{- define "mcp-mcpo-helm.tplvalues.render" -}}
{{- $root := index . 0 -}}
{{- $vals := index . 1 -}}
{{- tpl (toYaml $vals) $root }}
{{- end }}

{{/* Extra volumes for pod spec */}}
{{- define "mcp-mcpo-helm.extraVolumes" -}}
{{- if .Values.extraVolumes }}
{{- include "mcp-mcpo-helm.tplvalues.render" (list . .Values.extraVolumes) }}
{{- end }}
{{- end }}

{{/* Extra volume mounts for containers */}}
{{- define "mcp-mcpo-helm.extraVolumeMounts" -}}
{{- if .Values.extraVolumeMounts }}
{{- include "mcp-mcpo-helm.tplvalues.render" (list . .Values.extraVolumeMounts) }}
{{- end }}
{{- end }}

{{/* Extra environment variables for containers */}}
{{- define "mcp-mcpo-helm.extraEnvs" -}}
{{- if .Values.extraEnvs }}
{{- include "mcp-mcpo-helm.tplvalues.render" (list . .Values.extraEnvs) }}
{{- end }}
{{- end }}

{{/* Compute ingress path with regex suffix when path prefix is set */}}
{{- define "mcp-mcpo-helm.ingressPath" -}}
{{- if and .Values.ingress.path (ne .Values.ingress.path "/") -}}
{{ printf "%s(/|$)(.*)" .Values.ingress.path }}
{{- else -}}
/
{{- end -}}
{{- end }}

{{/* Ensure regex annotation for custom ingress paths */}}
{{- define "mcp-mcpo-helm.ingressUseRegex" -}}
{{- if and (ne .Values.ingress.path "/") (not (hasKey .Values.ingress.annotations "nginx.ingress.kubernetes.io/use-regex")) -}}
{{- $_ := set .Values.ingress.annotations "nginx.ingress.kubernetes.io/use-regex" "true" -}}
{{- end -}}
{{- end }}

{{/* Render mcpo configuration as pretty JSON */}}
{{- define "mcp-mcpo-helm.config" -}}
{{- .Values.config | toPrettyJson }}
{{- end }}
