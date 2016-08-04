FROM sebp/elk

RUN apt-get update && apt-get install -y --force-yes vim curl

RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/v2.1.1 open http://localhost:9200/_plugin/kopf

EXPOSE  5601 9200 5044 5000