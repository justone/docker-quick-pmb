FROM       nate/rabbitmq-ssl-stomp
MAINTAINER Nate Jones <nate@endot.org>

RUN apt-get install pwgen -y

ADD run.sh /scripts/run.sh
RUN chmod +x /scripts/run.sh
