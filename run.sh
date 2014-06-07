#!/bin/bash

# set up ssl and perms like parent image
/scripts/ssl.sh &> /dev/null
/scripts/perms.sh &> /dev/null

DONEFILE=/pmb_setup_complete
if [[ ! -e $DONEFILE ]]; then
    /usr/sbin/rabbitmq-server &

    # wait for rabbit to start
    HOSTNAME=$(hostname)
    /usr/sbin/rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@$HOSTNAME.pid

    ADMINPASS=$(pwgen 15 1)
    PASSWORD=$(pwgen 15 1)
    USERNAME=pmb

    # create pmb user
    /usr/sbin/rabbitmqctl add_user $USERNAME $PASSWORD
    /usr/sbin/rabbitmqctl set_permissions -p / $USERNAME "^$USERNAME-.*" "^$USERNAME-.*" "^$USERNAME-.*"

    # set guest password
    /usr/sbin/rabbitmqctl change_password guest $ADMINPASS

    # stop
    /usr/sbin/rabbitmqctl stop &> /dev/null
    sleep 1

    # mark setup as complete
    touch $DONEFILE

cat <<EOM

Quick Personal Message Bus Docker container.

    USER: $USERNAME
    PASS: $PASSWORD
    ADMIN USER: guest
    ADMIN PASS: $ADMINPASS

    CONFIG for PMB:

    export PMB_PRIMARY_URI=amqps://${USERNAME}:${PASSWORD}@[hostname]:[port]/
    export PMB_SSL_INSECURE_SKIP_VERIFY=1

EOM

fi

/usr/sbin/rabbitmq-server &> /dev/null
