# magnolia-helm

Helm Chart for Magnolia CMS.

This chart deploys a Magnolia CMS instance (author or public) and if desired
configures it to use a data base for its backend storage.

It's designed for one signle author and one single public instance. Multiple
public instances are work in progress.

## Configuration

The tomcat setup is derived from the public tomcat helm chart and uses init
containers the copy the actual webapp to the `webapps` folder.

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
to issue certificates with Let's Encrypt.

You have to first specify the host names you want certificates for and uncomment
the annotation used by cert-manager to auto-issue certificates from Let's encrypt:

```yaml
ingress:
  enabled: True
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
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
