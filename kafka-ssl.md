# Kafka / SSL

## Gerando certificados



```bash 
sudo mkdir /home/administrator/kafka/config/certs
sudo chown -R ubuntu:ubuntu /home/administrator/kafka/config/certs
cd /home/administrator/kafka/config/certs
cat <<EOF > $(pwd)/generate-certs.sh
#!/bin/bash

PASSWORD="********"
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

### Zookeeper Services

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

### Kafka Service

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

## Configurações

### Zookeeper

```bash
vim /home/administrator/kafka/config/zookeeper.properties
```

```bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# the directory where the snapshot is stored.
dataDir=/var/zookeeper
# the port at which the clients will connect
clientPort=2181
# disable the per-ip limit on the number of connections since this is a non-production config
maxClientCnxns=0
# Disable the adminserver by default to avoid port conflicts.
# Set the port to something non-conflicting if choosing to enable this
admin.enableServer=false
# admin.serverPort=8080
```

### Kafka

```bash
vim /home/administrator/kafka/config/server.properties
```

#### Remover as linhas

```bash
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN

authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
allow.everyone.if.no.acl.found=true
listeners=SASL_PLAINTEXT://0.0.0.0:9092
advertised.listeners=SASL_PLAINTEXT://10.83.102.23:9092
```

#### Adicionar as linhas

```bash
listeners=SSL://10.83.102.23:9092,PLAINTEXT://localhost:9093
advertised.listeners=SSL://10.83.102.23:9092,PLAINTEXT://localhost:9093
listener.security.protocol.map=SSL:SSL,PLAINTEXT:PLAINTEXT


ssl.keystore.location=/home/administrator/kafka/config/certs/kafka.server.keystore.jks
ssl.keystore.password=******
ssl.key.password=*****

ssl.truststore.location=/home/administrator/kafka/config/certs/kafka.server.truststore.jks
ssl.truststore.password=******

ssl.endpoint.identification.algorithm=
ssl.client.auth=required
security.protocol=SSL
security.inter.broker.protocol=SSL
```

