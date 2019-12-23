FROM wurstmeister/kafka:2.11-1.0.2

RUN apk add --no-cache krb5

COPY kafka-server-start.sh $KAFKA_HOME/bin/kafka-server-start.sh
COPY server.properties $KAFKA_HOME/config/server.properties

ADD start-kafka.sh /usr/bin/start-kafka.sh
RUN chmod a+x /usr/bin/start-kafka.sh

CMD ["start-kafka.sh"]