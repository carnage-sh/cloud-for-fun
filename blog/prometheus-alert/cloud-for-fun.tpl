{{ define "slack.default.title" }}Prometheus alerts (datacenter: {{ .GroupLabels.datacenter }}){{ end }}
{{ define "slack.cloudforfun.text" }}Alert {{ .GroupLabels.alertname }} on {{ .GroupLabels.instance }}{{ end }}
