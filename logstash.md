# Logstash

## Running with docker

```bash
docker run --rm -it \
    -e "xpack.security.enabled=false" \
    -e "xpack.monitoring.enabled=false" \
    -v $(pwd)/logstash/pipeline/:/usr/share/logstash/pipeline/ \
    -v $(pwd)/certificates/certs/:/etc/kafka/secrets \
    --net=poc-kafka_broker-kafka \
    docker.elastic.co/logstash/logstash:6.8.12
```

## Problema encontrados

Existe um bug para ignorar a validação do certificação, conforme o link <https://github.com/logstash-plugins/logstash-integration-kafka/issues/52>, por isso estamos utilizando uma versão antiga do logstash. O problema ocorre somente no plugin de output.

## References

* <https://docs.cloudera.com/HDPDocuments/HDP2/HDP-2.5.5/bk_security/content/ch_wire-kafka.html>
* <https://stackoverflow.com/questions/62590460/logstash-output-kafka-with-ssl-ssl-handshake-failed>
* <https://www.elastic.co/guide/en/logstash/current/plugins-outputs-kafka.html#plugins-outputs-kafka-client_id>
* <https://jaceklaskowski.gitbooks.io/apache-kafka/content/kafka-demo-ssl-authentication.html>
* <https://medium.com/analytics-vidhya/kafka-ssl-encryption-authentication-part-two-practical-example-for-implementing-ssl-in-kafka-d514f30fe782>
* <https://docs.microsoft.com/pt-br/azure/hdinsight/kafka/apache-kafka-ssl-encryption-authentication>
* <https://medium.com/@infobarbosa/kafka-ssl-authentication-lab-f5780d46fe03>