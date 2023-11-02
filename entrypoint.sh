#!/bin/sh

set -e

# use specified user name or use `default` if not specified
MY_USERNAME="${MY_USERNAME:-default}"

# use specified group name or use the same user name also as the group name
MY_GROUP="${MY_GROUP:-${MY_USERNAME}}"

# use the specified UID for the user
MY_UID="${MY_UID:-1000}"

# use the specified GID for the user
MY_GID="${MY_GID:-${MY_UID}}"


# check to see if group exists; if not, create it
if grep -q -E "^${MY_GROUP}:" /etc/group > /dev/null 2>&1
then
  echo "INFO: Group exists; skipping creation"
else
  echo "INFO: Group doesn't exist; creating..."
  # create the group
  addgroup --gid "${MY_GID}" "${MY_GROUP}" 
fi


# check to see if user exists; if not, create it
if id -u "${MY_USERNAME}" > /dev/null 2>&1
then
  echo "INFO: User exists; skipping creation"
else
  echo "INFO: User doesn't exist; creating..."
  # create the user
  adduser --system --disabled-password --uid "${MY_UID}" --gid "${MY_GID}" --home "/home/${MY_USERNAME}" --shell /bin/bash "${MY_USERNAME}"

fi

echo "INFO: Set privilege for  ${MY_USERNAME}..."
 # add user to sudo group wihout password
usermod -aG sudo matter
usermod -aG root matter
echo "${MY_USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chmod -R 775  /var/run/
if [ ! -d  "/etc/config" ] 
then
  mkdir -p /etc/config
fi
chmod -R 775  /etc/config

# start myapp
echo "INFO: Running prpl Application SDK as ${MY_USERNAME}:${MY_GROUP} (${MY_UID}:${MY_GID})"

# exec and run the actual process specified in the CMD of the Dockerfile (which gets passed as ${*})
#mkdir /home/${MY_USERNAME}/ubus
#chown -R matter /home/${MY_USERNAME}/ubus
#exec su "${MY_USERNAME}" "${@}"
#exec "${@}"
exec /bin/bash