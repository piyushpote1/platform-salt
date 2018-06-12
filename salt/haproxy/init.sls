{% set grafana_domain = salt['pnda.get_hosts_for_role']('grafana')[0] + '.' +pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set grafana_ip = salt['pnda.get_ips_for_role']('grafana')[0] %}
{% set grafana_port = salt['pillar.get']('grafana:bind_port', 3000) %}
{% set knox_domain = salt['pnda.get_hosts_for_role']('knox')[0] + '.' +pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set knox_ip = salt['pnda.get_ips_for_role']['knox'][0] %}
{% set knox_port = salt['pillar.get']('knox:bind_port', 8443) %}
{% set jupyter_host = salt['pnda.get_hosts_for_rile']('jupyter')[0] %}
{% set jupyter_ip = salt['pnda.get_ips_for_role']('jupyter')[0] %}
{% set jupyter_port = salt['pillar.get']('jupyter:bind_port', 8000 %}

