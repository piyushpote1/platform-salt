
global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon

defaults
   log global
   mode http
   option httplog
   option dontlognull
   timeout connect 5000
   timeout client 50000
   timeout server 50000

frontend http_front
   bind *:80
   stats uri /haproxy?stats

   use_backend http_grafana if { path /grafana } or { path_beg /grafana/ }
   use_backend jupyter if { path /jupyter } or { path_beg /jupyter/ }

   default_backend knox

backend http_grafana
   http-request set-path %[path,regsub(^/grafana/?,/)]
   server {{ grafana_domain }} {{ grafana_ip }}:{{ grafana_port }}

backend knox
   server {{ knox_domain }} {{ knox_ip }}:{{ knox_port }}

backend jupyter
   acl p_folder_jupyter path_end -i /jupyter
   http-request set-path %[path]/ if p_folder_jupyter
   server {{ jupyer_host }} {{ jupyter_ip }}:{{ jupyter_port }}