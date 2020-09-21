# Kafka POC

Validar os  conceitos de segurança para o Apache Kafka.

Pontos de atenção:

* Authentication using SSL;
* Encryption of data in-flight using SSL / TLS

## Go Client - Used for tests

```bash
go get github.com/birdayz/kaf/cmd/kaf
echo 'source <(kaf completion zsh)' >> ~/.zshrc
```

## Without Security

### Running Kafka, Zookeeper and kafdrop

```bash
docker-compose -f docker-compose.yaml up
```

### Creating topic and message

```bash
kaf -b localhost:9092 topic create "without-security"
echo "my message" | kaf -b localhost:9092 produce without-security
```

<http://localhost:19000/>

## With Security - SSL

## Creating certificates

```bash
cd certificates
./docker-kafka-ssl-certs.sh
cd ..
```

### Running Kafka, Zookeeper and kafdrop - SSL Client

```bash
export KAFKA_SSL_SECRETS_DIR=$(pwd)/certificates/certs
docker-compose rm -f
docker-compose -f docker-compose-ssl.yaml up --force-recreate
```

### Test with logstash

#### Running with docker

```bash
docker run --rm -it \
    -e "xpack.security.enabled=false" \
    -e "xpack.monitoring.enabled=false" \
    -v $(pwd)/logstash/pipeline/:/usr/share/logstash/pipeline/ \
    -v $(pwd)/certificates/certs/:/etc/kafka/secrets \
    --net=poc-kafka_broker-kafka \
    docker.elastic.co/logstash/logstash:6.8.12
```

#### Problema encontrados

Existe um bug para ignorar a validação do certificação, conforme o link <https://github.com/logstash-plugins/logstash-integration-kafka/issues/52>, por isso estamos utilizando uma versão antiga do logstash. O problema ocorre somente no plugin de output.

### Security

<https://github.com/addoddelgrossi/kafka-test/blob/master/security.md>

## References

* <https://medium.com/@stephane.maarek/introduction-to-apache-kafka-security-c8951d410adf>
* <https://www.udemy.com/course/apache-kafka-security/?couponCode=SEP_20_GET_STARTED>
* <https://github.com/obsidiandynamics/kafdrop#guides>
* <https://github.com/cswank/kcli>
* <https://github.com/birdayz/kaf>
* <https://github.com/birdayz/kaf/tree/master/examples>
* <https://docs.confluent.io/3.2.2/installation/docker/docs/tutorials/clustered-deployment-sasl.html>
* <https://github.com/confluentinc/cp-docker-images/issues/332>
* <https://hub.docker.com/r/obsidiandynamics/kafka>
* <https://github.com/confluentinc/cp-docker-images/issues/488>
* <https://github.com/confluentinc/cp-docker-images/issues/657>
* <https://docs.confluent.io/4.0.0/installation/docker/docs/configuration.html>
* <https://rmoff.net/2018/08/02/kafka-listeners-explained/>
* <https://docs.microsoft.com/pt-br/azure/hdinsight/kafka/apache-kafka-ssl-encryption-authentication>