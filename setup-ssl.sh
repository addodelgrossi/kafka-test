#!/bin/bash

export PASSWORD="xxxxxx"

rm -Rf certs
mkdir -p certs/{ca,server,client}

sudo /usr/share/elasticsearch/bin/elasticsearch-certutil ca --pass $PASSWORD --out $(pwd)/energisa-kafka-ca.p12
sudo chown ubuntu:ubuntu  *.p12

openssl pkcs12 -in $(pwd)/energisa-kafka-ca.p12 -nocerts -nodes -passin pass:$PASSWORD | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > ca-key
openssl pkcs12 -in $(pwd)/energisa-kafka-ca.p12 -clcerts -nokeys -passin pass:$PASSWORD | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ca-cert


# CA
cp ca-key certs/ca/ca-key
cp ca-cert certs/ca/ca-cert
# openssl req -new -newkey rsa:4096 -days 365 -x509 -subj "/CN=My Company" -keyout certs/ca/ca-key -out certs/ca/ca-cert -nodes

# --- SERVER --- 
# KeyStore
keytool -genkey -keystore certs/server/server.keystore.jks -validity 365 -storepass $PASSWORD -keypass $PASSWORD -dname "CN=kafka" -storetype pkcs12
# CSR
keytool -keystore certs/server/server.keystore.jks -certreq -file certs/server/csr -storepass $PASSWORD -keypass $PASSWORD
# CSR Signed with the CA
openssl x509 -req -CA certs/ca/ca-cert -CAkey certs/ca/ca-key -in certs/server/csr -out certs/server/csr-signed -days 365 -CAcreateserial -passin pass:$PASSWORD
# Import CA certificate in KeyStore
keytool -keystore certs/server/server.keystore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt
keytool -keystore certs/server/server.keystore.jks -alias CAinter -import -file <intermediate> -storepass $PASSWORD -keypass $PASSWORD -noprompt
# Import Signed CSR In KeyStore
keytool -keystore certs/server/server.keystore.jks -import -file certs/server/csr-signed -storepass $PASSWORD -keypass $PASSWORD -noprompt
# Import CA certificate In TrustStore
keytool -keystore certs/server/server.truststore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt

# --- CLIENT --- 
# KeyStore
keytool -genkey -keystore certs/client/client.keystore.jks -validity 365 -storepass $PASSWORD -keypass $PASSWORD -dname "CN=client" -storetype pkcs12
# CSR
openssl req -new -newkey rsa:4096 -subj "/CN=My Company" -nodes -keyout certs/client/cli.key -out certs/client/cli.csr
# CSR Signed with the CA
openssl x509 -req -CA certs/ca/ca-cert -CAkey certs/ca/ca-key -in certs/client/cli.csr -out certs/client/cli-signed.crt -days 365 -CAcreateserial -passin pass:$PASSWORD
# Import CA certificate in KeyStore
keytool -keystore certs/client/client.keystore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt
# Import Signed CSR In KeyStore
keytool -keystore certs/client/client.keystore.jks -alias kafkacli -import -file certs/client/cli-signed.crt -storepass $PASSWORD -keypass $PASSWORD -noprompt
# Import CA certificate In TrustStore
keytool -keystore certs/client/client.truststore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt
