###Adding LetsEncrypt certificates to a Java KeyStore

This guide is designed for apache users who wish to add their LetsEncrpyt (LE) certs to a Java KeyStore (JKS).
Although not a definitive guide to LE usage it should be possible to take the basics of this guide and use it to import your LE certs into a JKS in non-apache environments.

####Download and install Letsencrypt.

```
# git clone https://github.com/letsencrypt/letsencrypt

Cloning into 'letsencrypt'...
remote: Counting objects: 34758, done.
remote: Compressing objects: 100% (38/38), done.
remote: Total 34758 (delta 17), reused 0 (delta 0), pack-reused 34720
Receiving objects: 100% (34758/34758), 9.30 MiB | 4.19 MiB/s, done.
Resolving deltas: 100% (24690/24690), done.

# cd letsencrypt

letsencrypt# ./letsencrypt-auto --help

Checking for new version...
Creating virtual environment...
Installing Python packages...
Installation succeeded.

---- output cut -----

~/letsencrypt# ./letsencrypt-auto --apache --email admin@example.com -d example.com -d www.example.com -d other.example.net

```

Ensure all hosts which you are requesting certificates for are set up in DNS and configured as virtual web servers in apache.  The LE script will make the certificate call to the CA, however you will only be able to create certs for domains that are publicly available. LE will attempt to validate that the request is being made from the domains/hosts requesting the certs. It does this by placing a temporary folder/file in the root of each apache vhost for which a cert is being requested and passing that in the request to the CA. The CA then validates the temp file is accessible and once confirmed generates and deploys the cert.

Once deployed you should be able to find your PEM files in ```/etc/letsencrypt/domain/live```

LE allows you to create one cert for multiple domains/hosts as long as each are specified on the command line with the –d option and each one is accessible to the LE CA for validation. When initially setting up multiple domains it would be beneficial to host them all on the one server running LE. Once you have obtained your certs you can then distribute them to individual servers if you so wish.

###Now create your JKS.

First create a PKCS12 file containing full chain and private key.
```
# openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out pkcs.p12 -passout pass:[PKCSPWD] -name [NAME]
```

Now convert your PKCS12 file to a Java Keystore
```
# keytool -importkeystore -deststorepass [STOREPWD] -destkeypass [STOREPWD] -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass [PKCSPWD] -alias [NAME]
```

et voilà. You are now the proud owner of a JKS ```keystore.jks``` containing your LE certs. 

### N.B.
Remember to update the JKS every time you update your certs.
