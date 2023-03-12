# openssl
openssl commands to create local CA, Intermediate, Server and Client certificates using openssl configuration files.

# Preparation

Below script create the folder structure for CA and Intermediate certificates.

```
./prepareFolders.sh
```


# Root CA

```
./createCA.sh
```

# Intermediate CA

```
./createIntermediate.sh yourIntermediateName
```

# Certificates

## Server

```
./createCertificate-server.sh yourIntermediateName www.your-server-name.com
```

## Client

```
./createCertificate-client.sh yourIntermediateName clientName
```

# Resources

openssl docs:
- https://www.openssl.org/docs/man3.0/man1/openssl-genrsa.html
- https://www.openssl.org/docs/man3.0/man1/openssl-req.html

The openssl shell scripts are based on 
- https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
- https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html
- https://jamielinux.com/docs/openssl-certificate-authority/sign-server-and-client-certificates.html