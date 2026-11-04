#!/usr/bin/env bash

{{ if eq .Data.user.password "iompi" }}
chage -d 0 {{ .Data.user.name }}
echo "* The default password must be changed at the next login."
{{ end }}
