{% set grafana_domain = salt['pnda.get_hosts_for_role']('grafana')[0] + '.' +pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set grafana_ip = salt['pnda.get_ips_for_role']('grafana')[0] %}
{% set grafana_port = salt['pillar.get']('grafana:bind_port', 3000) %}
{% set knox_domain = salt['pnda.get_hosts_for_role']('knox')[0] + '.' +pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set knox_ip = salt['pnda.get_ips_for_role']['knox'][0] %}
{% set knox_port = salt['pillar.get']('knox:bind_port', 8443) %}
{% set jupyter_host = salt['pnda.get_hosts_for_rile']('jupyter')[0] %}
{% set jupyter_ip = salt['pnda.get_ips_for_role']('jupyter')[0] %}
{% set jupyter_port = salt['pillar.get']('jupyter:bind_port', 8000 %}
{% set pnda_home_dir = pillar['pnda']['homedir'] %}
{% set haproxy_config_dir = '/etc/haproxy' %}
{% set haproxy_lib_dir = '/var/lib/haproxy'}
{% set haproxy_stats_file = 'stats'}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set haproxy_version = pillar['haproxy']['version'] %}
{% set haproxy_package = 'haproxy-' + haproxy_version + '.tar.gz' %}
{% set haproxy_url = mirror_location + haproxy_package %}

# add a new user for HAProxy to be run under
haproxy-create_user:
  user.present:
    - name: haproxy
    - gid_from_name: True
    - groups:
      - haproxy

# download haproxy binary from mirror and extract
haproxy-install:
  archive.extracted:
    - name: {{ pnda_home_dir }}
    - source: {{ haproxy_url }}
    - source_hash: {{ haproxy_url }}.sha1
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ pnda_home_dir }}/haproxy-{{ haproxy_version }}

# create soft link to haproxy dir
haproxy-create_soft_link:
  cmd.run:
    - name: 'ln -s {{ pnda_home_dir }}/haproxy-{{ haproxy_version}} {{ pnda_home }}/haproxy'
    - unless: ls {{ pnda_home_dir }}/haproxy

# create soft link to haproxy binary
haproxy-create_binary_soft_link:
  cmd.run:
    - name: 'ln -s {{ pnda_home_dir }}/haproxy /usr/sbin/haproxy'

# create haproxy configuration directory
haproxy-create_conf_dir:
  file.directory:
    - name: '{{ haproxy_config_dir }}'

# create haproxy library directory
haproxy_create_lib_dir:
  file.directory:
  	- name: '{{ haproxy_lib_dir }}'

# add haproxy statistics file
haproxy_create_empty_stats_file:
  cmd.run:
    - name: 'touch {{ haproxy_lib_dir }}/stats'

# create configuration using template
haproxy_create_config:
  file.managed:
    - source: salt://haproxy/templates/haproxy.cfg.tpl
    - name: {{ haproxy_config_dir }}/haproxy.cfg
    - template: jinja
    - defaults:
    	grafana_domain: {{ grafana_domain }}
    	grafana_ip: {{ grafana_ip }}
    	grafana_port: {{ grafana_port }}
    	knox_domain: {{ knox_domain }}
    	knox_ip: {{ knox_ip }}
    	knox_port: {{ knox_port }}
    	jupyer_host: {{ jupyer_host }}
    	jupyter_ip: {{ jupyter_ip }}
    	jupyter_port: {{ jupyter_port }}

# set up haproxy systemd service
haproxy_systemd:
  file.managed:
    - name: /etc/init.d/haproxy
    - source: {{ pnda_home_dir }}/haproxy/examples/haproxy.init
    - mode: 755

# reload systemd
haproxy_systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable haproxy

# start haproxy service
haproxy_start_service:
  cmd.run:
    - name: 'service haproxy stop || echo already stopped; service haproxy start'



