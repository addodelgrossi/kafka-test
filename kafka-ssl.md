# Kafka / SSL

## Gerando certificados

```bash 
sudo mkdir /opt/kafka/config/certs
sudo chown -R ubuntu:ubuntu /opt/kafka/config/certs
cd /opt/kafka/config/certs
cat <<EOF > $(pwd)/generate-certs.sh
#!/bin/bash

PASSWORD="energisa"
SERVER_KEYSTORE_JKS="kafka.server.keystore.jks"
SERVER_KEYSTORE_P12="kafka.server.keystore.p12"
SERVER_KEYSTORE_PEM="kafka.server.keystore.pem"
SERVER_TRUSTSTORE_JKS="kafka.server.truststore.jks"
CLIENT_TRUSTSTORE_JKS="kafka.client.truststore.jks"

(
echo "Generating new Kafka SSL certs..."
keytool -keystore $SERVER_KEYSTORE_JKS -alias localhost -validity 730 -genkey -storepass $PASSWORD -keypass $PASSWORD \
  -dname "CN=kafka.docker.ssl, OU=None, O=None, L=London, S=London, C=UK"
openssl req -new -x509 -keyout ca-key -out ca-cert -days 730 -passout pass:$PASSWORD \
   -subj "/C=UK/S=London/L=London/O=None/OU=None/CN=kafka.docker.ssl"
keytool -keystore $SERVER_TRUSTSTORE_JKS -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
keytool -keystore $CLIENT_TRUSTSTORE_JKS -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
keytool -keystore $SERVER_KEYSTORE_JKS -alias localhost -certreq -file cert-file -storepass $PASSWORD -noprompt
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 730 -CAcreateserial -passin pass:$PASSWORD
keytool -keystore $SERVER_KEYSTORE_JKS -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
keytool -keystore $SERVER_KEYSTORE_JKS -alias localhost -import -file cert-signed -storepass $PASSWORD -noprompt
keytool -importkeystore -srckeystore $SERVER_KEYSTORE_JKS -destkeystore $SERVER_KEYSTORE_P12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $PASSWORD -deststorepass $PASSWORD -noprompt
# PEM for KafkaCat
openssl pkcs12 -in $SERVER_KEYSTORE_P12 -out $SERVER_KEYSTORE_PEM -nodes -passin pass:$PASSWORD
# chmod +rx *
)
EOF


chmod +x $(pwd)/generate-certs.sh
./generate-certs.sh
```

### Ajustanto os serviços

### Zookeeper

```bash
vim zookeeper.service
```

```bash
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=administrator
ExecStart=/home/administrator/kafka/bin/zookeeper-server-start.sh /home/administrator/kafka/config/zookeeper.properties
ExecStop=/home/administrator/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

### Kafka

```bash
vim kafka.service
```

```bash
[Unit]
Requires=zookeeper.service
After=zookeeper.service network.target

[Service]
Type=simple
User=administrator
ExecStart=/bin/sh -c '/home/administrator/kafka/bin/kafka-server-start.sh /home/administrator/kafka/config/server.properties > /home/administrator/kafka/kafka.log 2>&1'
ExecStop=/home/administrator/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal
Restart=always
RestartSec=180

[Install]
WantedBy=multi-user.target
```
