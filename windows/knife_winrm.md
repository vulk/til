# Starting Scheduled Tasks over knife winrm

knife winrm requires quite a few parms to work with ec2 instances, particularly if you use ec2 with ssl.

```
knife winrm \
  --ssl-peer-fingerprint 00C2E3167A93E9D7259D576B3E175FF450688E71 \
  --winrm-transport ssl \
  --winrm-port 5986 \
  --winrm-password XXXX \
  -m 10.113.68.20
```

That's a lot to copy/write down, so I use a wrapper script to set the variables I need:

### creds

```bash
#!/usr/bin/env bash
export NODE_NAME="$*"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=running" | jq .Reservations[0].Instances[0].InstanceId | sed -e 's/\"//g')
FINGERPRINT=$(aws ec2 get-console-output --instance-id $INSTANCE_ID | jq -r '.Output' | grep RDPCERTIFICATE-THUMBPRINT | tail -1 | awk '{print $4}')
export FINGERPRINT=${FINGERPRINT//[$'\t\r\n ']} # get rid of newlines etc
export IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID  | grep PrivateIpAddress |tail -1 | awk -F '"' '{print $4}')
CUSTOMER=chef
ACCOUNT=default
export PASSWORD=$(aws ec2 get-password-data --instance-id $INSTANCE_ID --priv-launch-key $HOME/.chef/keys/${CUSTOMER}_${ACCOUNT} | grep PasswordData | awk -F '"' '{print $4}')

echo export NODE_NAME="$NODE_NAME"
echo export PASSWORD=\"$PASSWORD\"
echo export IP="$IP"
echo export INSTANCE_ID="$INSTANCE_ID"
echo export FINGERPRINT="$FINGERPRINT"
```

I then use these creds inside a ```winrm``` script:

### winrm

```bash
#!/usr/bin/env bash
if [ "$NODE_NAME" != "$1" ]
then
		NODE_NAME=$1
		CREDS="$( dirname "${BASH_SOURCE[0]}" )/creds"
		echo Retrieving instance id and ip address and password for $NODE_NAME
		echo Cache by running \'eval \$\("$CREDS $NODE_NAME"\)\' before hand
	 eval $($CREDS $NODE_NAME)
else
	 echo Using cached instance id and ip address and password for $NODE_NAME
fi
shift
ARGS="$*"
knife winrm --ssl-peer-fingerprint "$FINGERPRINT" --winrm-transport ssl --winrm-port 5986 --winrm-password "$PASSWORD" -m $IP "$*" | sed -e "s:$IP ::"
```

There is also an rdp script, to enter those pesky passwords automatically on secure instances you can't copy past to:

### rdp

```bash
#!/usr/bin/env bash
if [ "$NODE_NAME" != "$1" ]
then
		NODE_NAME=$*
		echo Retrieving instance id and ip address and password for $NODE_NAME
		CREDS="$( dirname "${BASH_SOURCE[0]}" )/creds"
		eval $($CREDS $NODE_NAME)
else
		echo Using cached instance id and ip address and password for $NODE_NAME
fi

killall rdesktop
#rdesktop -g 1100x740 -u Administrator -p "${PASSWORD}" -r sound:local -r disk:prov=`pwd` $IP &
#rdesktop -g 1100x1240 -u Administrator -p "${PASSWORD}" -r sound:local -r disk:prov=`pwd` $IP &
rdesktop -g 1200x1800 -u Administrator -p "${PASSWORD}" -r sound:local -r disk:prov=`pwd` $IP &
# would be nice to poll the above output for 'connected'
echo "Wait for a connection"
sleep 24.0
echo "Focus on RDP Client"
xdotool search -name rdesktop windowactivate
echo "Get rid of security notice"
xdotool key Return
echo "Wait for password field"
sleep 5.25
echo "Move to password field"
xdotool key Tab
sleep 3.25
echo "Type password"
xdotool type "$PASSWORD"
sleep 3.25
echo "Login!"
xdotool key Return
```
