apiVersion: v2
appVersion: "6.1"
description: A Helm chart for Magnolia CMS deployments
name: magnolia-helm
type: application
version: {{ .Env.CHART_VERSION }}
keywords:
    - magnolia
    - magnolia-cms
home: https://www.magnolia-cms.com/
sources:
    - https://gitlab.com/mironet/magnolia-backup
    - https://gitlab.com/mironet/magnolia-bootstrap
maintainers:
    - name: MiroNet AG
      email: mathias.seiler@mironet.ch
    - name: fastforward websolutions
      email: pzingg@fastforward.ch