# magnolia-helm

Helm Chart for Magnolia CMS.

This chart deploys a Magnolia CMS instance (author or public) and if desired
configures it to use a data base for its backend storage.

It's designed for one signle author and one single public instance. Multiple
public instances are work in progress.

[[_TOC_]]

## Configuration

The tomcat setup is derived from the public tomcat helm chart and uses init
containers the copy the actual webapp to the `webapps` folder.

### Rescue mode

To enable the [Groovy Rescue Console](https://documentation.magnolia-cms.com/display/DOCS61/Groovy+module#Groovymodule-RescueApp), deploy your Helm
release with the following flag:

```yaml
magnoliaAuthor:
    rescueMode: true
```

This only takes effect if Magnolia is already installed.

### Docker Image configuration

You can specify the tomcat image and tag in the values:

```yaml
image:
  tomcat:
    repository: tomcat
    tag: "9-jre11-slim"
  #...
```

The actual webapp is specified here:

```yaml
image:
  webarchive:
    repository: registry.gitlab.com/fastforward-websolutions/k8s/next-deployment
    tag: latest
  #...
```

The init container is expected to have an already "exploded" webapp in
`/magnolia`. Files in there will be copied into the `webapps` when starting tomcat.

To pull from private Docker registry (e.g. GitLab), you have to create a docker-registry secret:

```bash
kubectl create secret docker-registry gitlab-registry --docker-server=https://registry.gitlab.com --docker-username=<username> --docker-password=<password or token>
```

To use the token from above, specify `pullSecrets` inside `image:` section like the following:

```yaml
image:
  #...
  pullSecrets:
    - name: gitlab-registry
```

### Persistence

In the `magnoliaPublic/Author:` sections of the values you can configure the
Magnolia instances (public and author). This is an example with PostgreSQL as a
backend data base and it's the default.

```yaml
magnoliaAuthor:
  db:
    enabled: true
    repository: postgres
    tag: 11.5-alpine
    type: postgres
    name: author
    persistence:
      enabled: true
      size: 10Gi
```

If you enable persistence a PVC is created and you can also specify the
StorageClass. Each instance (author and public) only gets one single db.

If you like to enable shared database (aka [Jackrabbit Clustering](https://wiki.magnolia-cms.com/display/WIKI/Setting+up+a+Jackrabbit+Clustering)), you can configure the shared workspaces and db connection (same as above) like the following:

```yaml
sharedDb:
  enabled: false
  workspaces:
    - form2db
    - shop
  db:
    ...
```

### Libraries

If you need additional libraries (jars) you can specify them in the `jars:`
array.

To configure logging, you can use the following section:

```yaml
magnoliaAuthor:
  logging:
    level: DEBUG
    pattern: '{"level":"%p","timestamp":"%d{ISO8601}","file":"%c:%L","message":"%m"}%n'
    loggers:
      - name: my-logger
        level: ERROR
```

Under `loggers` it's possible to define additional loggers with the respective value.

### Convention expected from init containers

This chart expects the init container to contain an `/init.sh` script which is
called as the only command. As of now the only tasks expected from init
containers is to copy some files to a target directory specified by the env var
`INIT_DEST`.

## Monitoring / Liveness

As a default, we monitor the public instance via a call to `/` for liveness. You
can change these settings in the `magnoliaPublic/Author` dicts:

```yaml
magnoliaPublic:
  #...
  livenessProbe:
    path: /author
    port: 8080
    failureThreshold: 4
    initialDelaySeconds: 120
    timeoutSeconds: 10
    periodSeconds: 30
```

## TLS

When run in a Kubernetes environment we expect `cert-manager` to be present and
the ingress object should contain all annotations necessary for the cert manager
to issue certificates with eg. Let's Encrypt.

You have to first specify the host names you want certificates for and uncomment
the annotation used by cert-manager to auto-issue certificates from Let's encrypt:

```yaml
ingress:
  enabled: True
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: test.k8s.example.com
      paths:
        - /
  tls:
    - hosts:
      - test.k8s.example.com
```

### Config Maps

`magnolia.properties` and a corresponding `server.xml` file for the persistence
layer is generated and stored as a ConfigMap. It will be mounted in the
container when run.

### Backups / DB Dumps

The magnolia to s3 backup agent can be used for regular dumps and backups of the data bases.

#### Prerequisites

* S3 bucket with credentials (accesskey and secretkey)
* Secret in Kubernetes

#### Backup Configuration

You need to set at least the following values according to your environment. Please have a look at the [magnolia-backup documentation](https://gitlab.com/mironet/magnolia-backup) for an explanation of all settings.

```yaml
magnoliaAuthor:
  db:
    backup:
      enabled: True
      env:
      - name: MGNLBACKUP_CMD
        value: pg_dumpall
      - name: MGNLBACKUP_ARGS
        value: --host localhost --user postgres
      - name: MGNLBACKUP_S3_BUCKET
        value: magnoliabackups
      - name: MGNLBACKUP_S3_ACCESSKEY
        valueFrom:
          secretKeyRef:
            name: s3-backup-key
            key: accesskey
      - name: MGNLBACKUP_S3_SECRETKEY
        valueFrom:
          secretKeyRef:
            name: s3-backup-key
            key: secretkey
      - name: MGNLBACKUP_S3_ENDPOINT
        value: s3.example.com
      - name: MGNLBACKUP_S3_CYCLE
        value: "15,4,3"
```

The referenced secret needs to exist before rolling this out. Here's an example of how to create one:

```bash
# Create files needed for the rest of the example.
echo -n 's3user' > accesskey.txt
 echo -n 'supersecrets3pass' > secretkey.txt

kubectl create secret generic s3-backup-key --from-file=accesskey=./accesskey.txt --from-file=secretkey=./secretkey.txt

rm -f accesskey.txt secretkey.txt
```

(Also see the [official Kubernetes documentation about secrets](https://kubernetes.io/docs/concepts/configuration/secret/).)

This creates a new sidecar which takes backups every 24h each day. The backups are streamed directly to S3 without temporarily storing them locally, so this backup mechanism can be used for very large data base dumps without having to worry about local storage or memory.

#### Backup inspection

You can port-forward the backup service and see a list of current backups and also get direct download links for the S3 server:

```bash
 kubectl port-forward <your-release-name>-author-db-0 9999:9999
```

After the port forwarding is established, visit [http://localhost:9999/list](http://localhost:9999/list) for a list of backups.

### Activation keypair generation

#### Technical background

Magnolia uses a public/private key system for content activation from author to public instances. If that key is nonexistent on the first boot it will be generated by Magnolia itself. While this is convenient it makes the application somewhat stateful. Generating a RSA key out of a passphrase (a secret for example) is theoretically possible but not easy (nor secure) to do.

#### Automatically generated key

This is the easiest approach. A `emptyDir` will be created by the pod and mounted for the purpose of storing the automatically generated activation key. You don't have to configure anything for this and it is the default. But use of this approach is not recommended in production. You can always switch to the manual secret method below after doing this.

#### Secrets

You can specify which secret the pods should be looking for to mount the key `.properties` file at the correct location. The format of the activation key file is like follows:

```text
#generated 09.May.2020 04:55 by superuser
#Sat May 09 16:55:03 CEST 2020
key.private=30820277020100300...
key.public=30819F300D06092A8648...
```

You can manually generate it like explained below:

#### Direct key input

Magnolia requires RSA keypair properties for the publication mechanism. You
can generate a keypair e.g. with `openssl`. **Magnolia can handle at most 1024 bit key length:**

```bash
mkdir temp
openssl genrsa -out temp/key.pem 1024
openssl rsa -in temp/key.pem -pubout -out temp/pubkey.pem
```

Now you can create the `activation.properties` secret:

```bash
echo key.private=$(cat temp/key.pem | hexdump  -e '"%X"') > temp/secret.yml
echo key.public=$(cat temp/pubkey.pem | hexdump  -e '"%X"') >> temp/secret.yml
kubectl create secret generic activation-key --from-file=activation-secret=temp/secret.yml
```

The configuration in your `values.yml` should reference this secret so it will be loaded:

```yaml
bootstrap:
  enabled: True

magnoliaAuthor:
  activation:
    useExistingSecret: True
    secret:
      name: activation-key
      key: activation-secret

magnoliaPublic:
  activation:
    useExistingSecret: True
    secret:
      name: activation-key
      key: activation-secret
```

## Status

This chart is currently used in production. We will adhere to the semver standard and try to maintain backwards compatiblity within major releases.

## Legal Notes

Magnolia, Magnolia Blossom, Magnolia and the Magnolia logo are registered
trademark or trademarks of Magnolia International Ltd.
