# Kafka SSL

## Configure Server

### Gerando o certificado e a keystore

(-dname "CN=kafka1.infobarbosa.github.com" )

```bash
export SRVPASS=serversecret
keytool -genkey -keystore kafka.server.keystore.jks -validity 365 -storepass $SRVPASS -keypass $SRVPASS -storetype pkcs12
keytool -list -v -keystore kafka.server.keystore.jks -storepass $SRVPASS
```

### Certification request

```bash
keytool -keystore kafka.server.keystore.jks -certreq -file cert-file -storepass $SRVPASS -keypass $SRVPASS
```

### Assinar o certificado

```bash
export SRVPASS=serversecret
sudo openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:$SRVPASS
```


## Client Key

```bash
export CLIPASS=clientpass
keytool -genkey -keystore kafka.client.keystore.jks -validity 365 -storepass $CLIPASS -keypass $CLIPASS -alias kafka-client -storetype pkcs12
keytool -list -v -keystore kafka.client.keystore.jks -storepass $CLIPASS
```

```bash
keytool -keystore kafka.client.keystore.jks -certreq -file client-cert-sign-request -alias kafka-client -storepass $CLIPASS -keypass $CLIPASS
```

## Assinante o certificado

```bash

```


# References

 * <https://medium.com/@infobarbosa/kafka-ssl-authentication-lab-f5780d46fe03>
 * <https://stackoverflow.com/questions/54903381/kafka-failed-authentication-due-to-ssl-handshake-failed>