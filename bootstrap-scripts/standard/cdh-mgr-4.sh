#!/bin/bash -v

# This script runs on instances with a node_type tag of "cdh-mgr-4"
# It sets the roles that determine what software is installed
# on this instance by platform-salt scripts and the minion
# id and hostname

# The pnda_env-<cluster_name>.sh script generated by the CLI should
# be run prior to running this script to define various environment
# variables

set -e

cat >> /etc/salt/grains <<EOF
cloudera:
  role: MGR04
roles:
  - oozie_database
  - mysql_connector
  - hue
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-mgr-4
EOF

echo $PNDA_CLUSTER-cdh-mgr-4 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-mgr-4

service salt-minion restart