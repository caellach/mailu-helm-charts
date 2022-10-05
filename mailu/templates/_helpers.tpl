{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mailu.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailu.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create the claimName: existingClaim if provided, otherwise claimNameOverride if provided, otherwise mailu-storage (or other fullname if overriden)
*/}}
{{- define "mailu.claimName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else if .Values.persistence.claimNameOverride -}}
{{- .Values.persistence.claimNameOverride -}}
{{- else -}}
{{ include "mailu.fullname" . }}-storage
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mailu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the cluster domain name or default to cluster.local
*/}}
{{- define "mailu.clusterDomain" -}}
{{- if .Values.clusterDomain -}}
{{- .Values.clusterDomain -}}
{{- else -}}
cluster.local
{{- end -}}
{{- end -}}

{{ define "mailu.rspamdClamavClaimName"}}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.rspamd_clamav_persistence.claimNameOverride | default (printf "%s-rspamd-clamav" (include "mailu.fullname" .)) }}
{{- end }}


{{/*
Get the certificates secret name
*/}}
{{- define "mailu.certificatesSecretName" -}}
{{ printf "%s-certificates" (include "mailu.fullname" . ) }}
{{- end -}}

{{/*

{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "getValueFromSecret" }}
{{- $len := (default 16 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64dec -}}
{{- else -}}
{{- randAlphaNum $len -}}
{{- end -}}
{{- end }}

{{/*
Return mailu secretKey
*/}}
{{- define "mailu.secretKey" -}}
{{- if .Values.secretKey }}
    {{- .Values.secretKey -}}
{{- else -}}
    {{- include "getValueFromSecret" (dict "Namespace" (include "common.names.namespace" .) "Name" (include "mailu.secretName" .) "Length" 10 "Key" "secret-key")  -}}
{{- end -}}
{{- end -}}

{{/*
Get the mailu secret name.
*/}}
{{- define "mailu.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" (tpl .Values.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "mailu.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return mailu initialAccount.password
*/}}
{{- define "mailu.initialAccount.password" -}}
{{- if .Values.initialAccount.password }}
{{- else -}}
    {{- include "getValueFromSecret" (dict "Namespace" (include "common.names.namespace" .) "Name" (include "mailu.initialAccount.secretName" .) "Length" 10 "Key" "initial-account-password")  -}}
{{- end -}}
{{- end -}}

{{/*
Return mailu initialAccount secret name
*/}}
{{- define "mailu.initialAccount.secretName" -}}
{{- if .Values.initialAccount.existingSecret }}
    {{- printf "%s" (tpl .Values.initialAccount.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-initial-account" (include "mailu.fullname" .) -}}
{{- end -}}
{{- end -}}

# {{/*
# Compile all warnings into a single message, and call fail.
# */}}
# {{- define "mailu.validateValues" -}}
# {{- $messages := list -}}
# {{- $messages := append $messages (include "mailu.validateValues.domain" .) -}}
# # {{- $messages := append $messages (include "postgresql.validateValues.psp" .) -}}
# # {{- $messages := append $messages (include "postgresql.validateValues.tls" .) -}}
# {{- $messages := without $messages "" -}}
# {{- $message := join "\n" $messages -}}

# {{- if $message -}}
# {{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
# {{- end -}}
# {{- end -}}

# {{/*
# Validate values - 'domain' needs to be set
# */}}
# {{- define "mailu.validateValues.domain" -}}
# {{- if not .Values.domain }}
# mailu: domain
#     You need to set the domain to be used
# {{- end -}}
# {{- end -}}