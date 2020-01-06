###Adding LetsEncrypt certificates to a Java KeyStore

This guide is designed for apache users who wish to add their LetsEncrypt (LE) certs to a Java KeyStore (JKS).
Although not a definitive guide to LE usage it should be possible to take the basics of this guide and use it to import your LE certs into a JKS in non-apache environments.

####Download and install LetsEncrypt.

```

apt install software-properties-common
add-apt-repository ppa:certbot/certbot
apt update
apt install python-certbot-apache
cerbot -d [domain]

```

The second method will guide you through the certificate install process.
However once you are familiar with the process or wish to automatically renew certs you can make use of the command line arguments.
Full details on the usage of cerbot can be found [here](https://certbot.eff.org/docs/using.html).


Ensure all hosts which you are requesting certificates for are set up in DNS and configured as virtual web servers in apache.  The LE script will make the certificate call to the CA, however you will only be able to create certs for domains that are publicly available. LE will attempt to validate that the request is being made from the domains/hosts requesting the certs. It does this by placing a temporary folder/file in the root of each apache vhost for which a cert is being requested and passing that in the request to the CA. The CA then validates the temp file is accessible and once confirmed generates and deploys the cert.

Once deployed you should be able to find your PEM files in ```/etc/letsencrypt/domain/live```.

LE allows you to create one cert for multiple domains/hosts as long as each are specified on the command line with the –d option and each one is accessible to the LE CA for validation. When initially setting up multiple domains it would be beneficial to host them all on the one server running LE. Once you have obtained your certs you can then distribute them to individual servers if you so wish.

###Now create your JKS.

I've added a very simple makeKS.sh script to do this bit for you.
the script takes two parameters in the form of the cert folder location and the password to use for the jks.

e.g.
```

makeKS.sh /etc/letsencrypt/live/domain password

```
You will be prompted to input the password at the end of the script to verify the KeyStore file contents.

If you wish to perform this task manually use the following steps.

First create a PKCS12 file containing full chain and private key.
```
# openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out pkcs.p12 -passout pass:[PKCSPWD] -name [NAME]
```

Now convert your PKCS12 file to a Java Keystore.
```
# keytool -importkeystore -deststorepass [STOREPWD] -destkeypass [STOREPWD] -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass [PKCSPWD] -alias [NAME]
```

Validate the keystore.
```
keytool -list -keystore keystore.jks
```

et voilà. You are now the proud owner of a JKS ```keystore.jks``` containing your LE certs. 

### N.B.
Remember to update the JKS every time you update your certs.
