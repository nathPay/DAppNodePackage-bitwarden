#!/bin/sh

if [ "$EXTERNAL" == "false" ]
then
  mkdir /certs
  openssl genpkey -algorithm RSA -aes128 -out private-ca.key -outform PEM -pkeyopt rsa_keygen_bits:2048 -pass pass:somepassword
  openssl req -passin pass:somepassword -subj "/C=/ST=/L=/O=/OU=/CN=" -x509 -new -nodes -sha256 -days 3650 -key private-ca.key -out self-signed-ca-cert.crt
  openssl genpkey -algorithm RSA -out bitwarden.key -outform PEM -pkeyopt rsa_keygen_bits:2048
  openssl req -subj "/C=/ST=/L=/O=/OU=/CN=" -new -key bitwarden.key -out bitwarden.csr
  echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = bitwarden.public.dappnode" > bitwarden.ext
  openssl x509 -req --passin pass:somepassword -in bitwarden.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out bitwarden.crt -days 365 -sha256 -extfile bitwarden.ext
fi

/bitwarden_rs