# certificate preparation

In order to implement MITM for HTTPS traffic and to prevent browsers from displaying security warnings, a self-signed CA certificate needs to be generated and trusted

## Generate CA certificate

For security reasons, users must generate their own CA certificates. Random use of untrusted CA certificates will leave serious security risks

Experienced users can use OpenSSL to perform related operations by themselves. Considering users without relevant experience, you can use the following commands to directly generate relevant content. The generated certificate and private key will be stored in the `ca` directory

```shell
video-mitm.exe genca
```

After the browser uses the proxy provided by Video-MITM, by accessing [http://cert.mitm.plus](http://cert.mitm.plus) The certificate can be downloaded directly, which is very useful when providing services to other devices

## Trust the generated certificate

You need to trust the newly generated certificate in the browser or operating system, the specific method will be added later
