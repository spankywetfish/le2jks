#Delete old keystore file.
rm keystore.jks

#Export certs to pkcs.12 format
openssl pkcs12 -export -in $1/fullchain.pem -inkey $1/privkey.pem -out pkcs.p12 -passout pass:$2 -name LECert

#generate new jks
keytool -importkeystore -deststorepass $2 -destkeypass $2 -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass $2 -alias LECert


#Verify the jks
echo "validating keystore..."
keytool -list -keystore keystore.jks
