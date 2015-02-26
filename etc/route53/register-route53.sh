#!/bin/sh
# Original from David Fox:
# https://gist.github.com/dfox/1677405
#
# Script to bind a CNAME to our HOST_NAME in ZONE

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi

# Defaults
TTL=60
#HOST_NAME=`hostname`
HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
ZONE=NoZoneDefined

# Load configuration
. /etc/route53/config

# Export access key ID and secret for cli53
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Use command line scripts to get instance ID and public hostname
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
#INSTANCE_ID=$(ec2metadata | grep 'instance-id:' | cut -d ' ' -f 2)
#MY_NAME=$HOST_NAME
MY_NAME=$(curl http://169.254.169.254/latest/meta-data/instance-id)
#PUBLIC_HOSTNAME=$(/opt/aws/bin/ec2-metadata | grep 'public-hostname:' | cut -d ' ' -f 2)
PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

logger "ROUTE53: Setting DNS NS $MY_NAME.$ZONE to $PUBLIC_HOSTNAME"

echo "ROUTE53: Setting DNS NS $MY_NAME.$ZONE to $PUBLIC_HOSTNAME"

# Create a new NS record on Route 53, replacing the old entry if nessesary
echo /usr/bin/cli53 rrdelete "$ZONE" "$MY_NAME"
/usr/bin/cli53 rrdelete "$ZONE" "$MY_NAME"

echo /usr/bin/cli53 rrcreate "$ZONE" "$MY_NAME" NS "$PUBLIC_HOSTNAME" --replace --ttl "$TTL"
/usr/bin/cli53 rrcreate "$ZONE" "$MY_NAME" NS "$PUBLIC_HOSTNAME" --replace --ttl "$TTL"


echo /home/ec2-user/openshift.sh install_components=broker,named,activemq,datastore,node domain=$INSTANCE_ID.dlt-testdrive.com hosts_domain=$INSTANCE_ID.dlt-testdrive.com broker_hostname=broker.$INSTANCE_ID.dlt-testdrive.com named_entries=broker:$PUBLIC_IP,activemq:$PUBLIC_IP,node1:$PUBLIC_IP valid_gear_sizes=medium default_gear_size=medium default_gear_capabilities=medium node_hostname=node1.$INSTANCE_ID.dlt-testdrive.com

/home/ec2-user/openshift.sh install_method=rhsm rhn_user=dlteng rhn_pass=OOOOOOO! sm_reg_pool=NNNNNNNNN install_components=broker,named,activemq,datastore,node domain=$INSTANCE_ID.dlt-testdrive.com hosts_domain=$INSTANCE_ID.dlt-testdrive.com broker_hostname=broker.$INSTANCE_ID.dlt-testdrive.com named_entries=broker:$PUBLIC_IP,activemq:$PUBLIC_IP,node1:$PUBLIC_IP valid_gear_sizes=medium default_gear_size=medium default_gear_capabilities=medium node_hostname=node1.$INSTANCE_ID.dlt-testdrive.com
