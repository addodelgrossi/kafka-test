# Kafka Security

## Kafka Security Checklist

- [x] Encryption
- [x] Firewalls
- [x] Authentication
- [ ] Access Control
- [X] Isolation for ZooKeeper
- [x] Monitoring and alerting

### Encryption

Using a communications security layer, like TLS or SSL, will chip away at throughput and performance because encrypting and decrypting data packets requires processing power. However, the performance cost is typically negligible for an optimized Kafka implementation, especially with the more recent versions of Kafka. See our article on Kafka optimization for general use cases for more details on optimizing Kafka.

### Firewalls

Brokers should be located in a private network. Port-based and web-access firewalls are important for isolating both Kafka and ZooKeeper. Port-based firewalls limit access to a specific port number. Web-access firewalls limit access to a specific, limited group of possible requests. For more information on firewalls, see our posts about preventing data breaches.

### Authentication

Use SSL/SASL (simple authentication and security layer) for authentication of clients → brokers, between brokers, and brokers → tools. SSL authentication uses two ways authentication and is the most common approach for out-of-the-box managed services.

### Access Control

When granting access, it is important to set parameters for what information or sets of information a client has access to within Kafka. Employ access control lists (ACL) to limit which clients can read and/or write to a particular topic. This approach limits access and also sets a baseline for alerting off of abnormal behavior.

### Isolation for ZooKeeper

Isolating ZooKeeper is another crucial component to keeping the implementation secure. Zookeeper should not connect to the public internet, aside from rare use cases. ACLs can also be employed for ZooKeeper.

### Monitoring and alerting

Monitoring Kafka is an important component of securing Kafka. Kafka monitoring using Elasticsearch and Kibana outlines the key performance indicators for Kafka and how to observe them in real-time. For instance, in addition to monitoring access, an optimized Kafka monitoring setup will detect if unknown entities are accessing Kafka topics or known entities are acting irregularly.

With either machine learning based alerting or threshold based alerting, you can have the system notify you or your team in real-time if abnormal behavior is detected.

## Notes

- [ ] update certificates / expired
- [ ] secret Protection

### Secret Protection

Enabling encryption and security features requires the configuration of secret values, including passwords, keys, and hostnames. Kafka does not provide any method of protecting these values and users often resort to storing them in cleartext configuration files and source control systems. It’s common to see a configuration with a secret like this:

```bash
ssl.key.password=test1234
```

Common security practices dictate that secrets should not be stored as cleartext in configuration files as well as redacted from application logging output, preventing unintentional leakage of their value. Confluent Platform provides Secret Protection, which leverages envelope encryption, an industry standard for protecting encrypted secrets through a highly secure method.

Applying this feature results in configuration files containing instructions for a ConfigProvider to obtain the secret values instead of the actual cleartext value:

```bash
ssl.key.password=${securepass:secrets.file:server.properties/ssl.key.password}
```

## References

* <https://www.confluent.io/blog/secure-kafka-deployment-best-practices/>
* <https://www.linkedin.com/pulse/kafka-optimization-security-checklist-maria-hatfield-phd>
* <https://github.com/strimzi/strimzi-kafka-operator/issues/2680>
* <https://github.com/confluentinc/cp-docker-images/wiki/Getting-Started>
* <https://docs.microsoft.com/pt-br/azure/hdinsight/kafka/apache-kafka-ssl-encryption-authentication>
* <https://medium.com/analytics-vidhya/kafka-ssl-encryption-authentication-part-two-practical-example-for-implementing-ssl-in-kafka-d514f30fe782>
* <https://medium.com/@infobarbosa/kafka-ssl-authentication-lab-f5780d46fe03>
* <https://medium.com/weareservian/encryption-authentication-and-external-access-for-confluent-kafka-on-kubernetes-69c723a612fc>
* <https://www.confluent.io/blog/kafka-security-secret-encryption-with-confluent/>