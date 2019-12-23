#!/bin/bash

 # This script needs to be executed just once
 if [ -f /$0.completed ] ; then
   echo "$0 `date` /$0.completed found, skipping run"
   exit 0
 fi 
    
VIRTUAL_HOST=${VIRTUAL_HOST:-"/"}
ADMIN_LOGIN=${ADMIN_LOGIN:-"admin"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}
USER_LOGIN=${USER_LOGIN:-"user"}
USER_PASSWORD=${USER_PASSWORD:-"user"}
COBY_ADMIN_EXCHANGE=${COBY_ADMIN_EXCHANGE:-"coby-log-admin-exchange"}
COBY_USER_EXCHANGE=${COBY_USER_EXCHANGE:-"coby-log-user-exchange"}

# Wait for RabbitMQ startup
for (( ; ; )) ; do
  sleep 2
  rabbitmqctl -q node_health_check > /dev/null 2>&1
  if [ $? -eq 0 ] ; then
    echo "$0 `date` rabbitmq is now running"
    break
  else
    echo "$0 `date` waiting for rabbitmq startup"
  fi
done

# Add Virtual Host / 
rabbitmqctl add_vhost $VIRTUAL_HOST

# Execute RabbitMQ config commands here

# Create Admin user
rabbitmqctl add_user "$ADMIN_LOGIN" "$ADMIN_PASSWORD"
rabbitmqctl set_permissions -p $VIRTUAL_HOST $ADMIN_LOGIN ".*" ".*" ".*"
rabbitmqctl set_user_tags $ADMIN_LOGIN administrator
echo "$0 `date` user $ADMIN_LOGIN created"

# Create user
rabbitmqctl add_user $USER_LOGIN $USER_PASSWORD
rabbitmqctl set_permissions -p $VIRTUAL_HOST                              \
                            $USER_LOGIN                                   \
                            "($COBY_USER_EXCHANGE|stomp-subscription-).*" \
                            "($COBY_USER_EXCHANGE|stomp-subscription-).*" \
                            "($COBY_USER_EXCHANGE|stomp-subscription-).*"
                            
echo "$0 `date` user '$USER_LOGIN' created"


rabbitmqadmin -u $ADMIN_LOGIN -p $ADMIN_PASSWORD              \
              declare exchange name=$COBY_ADMIN_EXCHANGE      \
              type=fanout durable=true --vhost=$VIRTUAL_HOST  
              
rabbitmqadmin -u $ADMIN_LOGIN -p $ADMIN_PASSWORD              \
              declare exchange name=$COBY_USER_EXCHANGE       \
              type=fanout --vhost=$VIRTUAL_HOST 

rabbitmqadmin declare binding -u $ADMIN_LOGIN                 \
                              -p $ADMIN_PASSWORD              \
                              --vhost=$VIRTUAL_HOST           \
                              source=$COBY_ADMIN_EXCHANGE     \
                              destination=$COBY_USER_EXCHANGE \
                              destination_type=exchange

# Create mark so script is not ran again
touch /$0.completed
