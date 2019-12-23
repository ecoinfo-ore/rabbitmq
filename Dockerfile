
FROM rabbitmq:3.7

ENV RABBITMQ_DEFAULT_USER admin
ENV RABBITMQ_DEFAULT_PASS admin
 
RUN rabbitmq-plugins enable --offline rabbitmq_management
RUN rabbitmq-plugins enable --offline rabbitmq_mqtt
RUN rabbitmq-plugins enable --offline rabbitmq_web_stomp

RUN apt-get update && apt-get install -y wget && apt-get install -y python3 

RUN wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.7.23/bin/rabbitmqadmin
RUN chmod +x rabbitmqadmin
RUN sed -i 's|#!/usr/bin/env python|#!/usr/bin/env python3|' rabbitmqadmin
RUN mv rabbitmqadmin /usr/bin/

ADD init.sh /
ADD config_rabbit.sh /
RUN chmod +x /init.sh /config_rabbit.sh
ENTRYPOINT ["/init.sh"]

# Auto-health check to rabbit service status
HEALTHCHECK --interval=20s --timeout=5s --start-period=30s CMD rabbitmqctl status || exit 1
  
# amqp 
EXPOSE 5672  
# mqtt
EXPOSE 1883  
# htpp
EXPOSE 15672 
# web-stomp
EXPOSE 15674 

