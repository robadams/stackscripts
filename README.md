# Usage

1. Goto Linode Dashboard > StackScripts > Create New StackScript
2. Select Ubuntu18.04 or compatible image.
3. Add following to slack script:

```
#!/bin/bash

# <UDF name="host" Label="Host Name" /> # e.g. server-1, demo, etc.
# <UDF name="un" Label="User Name" /> # e.g. user
# <UDF name="pw" Label="User Password" example="password" /> e.g. password
# <UDF name="pk" Label="User SSH Pub Key" example="pub key" /> e.g. pub key that will be used to access server
# <UDF name="url" Label="URL of Provision Script" example="https://raw.githubusercontent.com/robadams/stackscripts/master/lamp.sh" />

exec > /root/stackscript.log

curl --request GET "$URL" > /root/provision.sh

source /root/provision.sh

provision "$HOST" "$UN" "$PW" "$PK"

```
