# Usage

Goto Linode Dashboard > StackScripts > Create New StackScript and add the following

```

#!/bin/bash

# <UDF name="host" Label="Host Name" /> # e.g. server-1, demo, etc.
# <UDF name="un" Label="User Name" /> # e.g. user 
# <UDF name="pw" Label="User Password" example="password" /> e.g. password
# <UDF name="pk" Label="User SSH Pub Key" example="pub key" /> e.g. pub key that will be used to access server
# <UDF name="url" Label="URL of Provision Script" example="" />

exec > /root/stackscript.log

curl --request GET "$URL" > /root/provision.sh

source /root/provision.sh

provision "$HOST" "$UN" "$PW" "$PK"

```
