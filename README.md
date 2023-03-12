# openssl
openssl commands to create local CA, Intermediate, Server and Client certificates.

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

# Server certificate

```
./createCertificate-server.sh yourIntermediateName www.your-server-name.com
```
