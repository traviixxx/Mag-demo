# Magnolia CMS Helm Chart

Helm Chart for [Magnolia CMS](https://www.magnolia-cms.com/).

This chart deploys Magnolia CMS as an author and one or more publics instances as `StatefulSets`.

[[_TOC_]]

## Install

Add the public Helm repository:

```bash
helm repo add mironet https://charts.mirohost.ch
helm repo update
helm install -g mironet/magnolia-helm
```

This generates a deployment name (`-g`) and deploys the latest released version of the chart.

## Upgrade

The basic upgrade from an older chart version to a newer one is done with:

```bash
# Latest version:
helm upgrade <release-name> mironet/magnolia-helm
# Specific version:
helm upgrade <release-name> mironet/magnolia-helm --version <version-string>
```

Usually upgrades should work fine but there might be cases where you will have to redeploy some or all of the resources because of changes which are not allowed on existing Kubernetes objects. Since the databases and other stateful parts of the deployment use PVC templates it should be safe to simply delete the deployment:

```bash
helm delete <release-name> # This will not remove volumes created by PVC templates (inside StatefulSets).
helm install ... # And reinstall.
```

If you want to do this non-disruptively in production we recommend you restore/clone the deployment to another environment, point external load balancers to the new deployment and then remove the old one.

## Values Reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bootstrap.enabled | bool | `true` | Do enable bootstrapping via REST. |
| deploy.directory | string | `"/usr/local/tomcat/webapps"` | Deploy into this directory innside the app server container. |
| deploy.extraLibs | string | `"/usr/local/tomcat/lib2"` |  |
| deploy.securityContext.fsGroup | int | `1000` | Fixup file permissions for volumes mounted to the Magnolia pod. |
| deploy.securityContext.runAsGroup | int | `1000` | Group ID. |
| deploy.securityContext.runAsUser | int | `1000` | Run application pod under this user ID. **Note:** Do not use a privileged user here. |
| deploy.tempDir | string | `"/usr/local/tomcat/temp"` |  |
| fullnameOverride | string | `""` |  |
| image.pullSecrets | list | `[]` |  |
| image.tomcat.pullPolicy | string | `"IfNotPresent"` | Tomcat repo pull policy. |
| image.tomcat.repository | string | `"tomcat"` | The tomcat image we're going to use. |
| image.tomcat.tag | string | `"9-jre11-slim"` | Tomcat repo tag. |
| ingress.annotations | object | {} | Additional annotations for the ingress object. |
| ingress.enabled | bool | `false` | Enable/disable ingress configuration. |
| ingress.hosts | list | `[]` | Specify hosts here as an array. |
| ingress.tls | list | `[]` |  |
| jars[0].env[0].name | string | `"INIT_DEST"` |  |
| jars[0].env[0].value | string | `"/app/magnolia/WEB-INF/lib"` |  |
| jars[0].initScript | string | `"/init.sh"` | Where to find the init script which copies .jar files into tomcat/lib. |
| jars[0].name | string | `"postgres-jdbc"` |  |
| jars[0].repository | string | `"registry.gitlab.com/mironet/magnolia-jar/postgres-42.2.8"` | Example of additional jar, here the Postgres JDBC driver. |
| jars[0].tag | string | `"v0.0.1"` |  |
| jars[1].env[0].name | string | `"INIT_DEST"` |  |
| jars[1].env[0].value | string | `"/extraLibs/"` |  |
| jars[1].initScript | string | `"/init.sh"` |  |
| jars[1].name | string | `"jmx-exporter"` |  |
| jars[1].repository | string | `"registry.gitlab.com/mironet/magnolia-jar"` |  |
| jars[1].tag | string | `"jmx_prometheus_javaagent-0.13.0"` |  |
| magnoliaAuthor | object | See values below ... | This is the author's configuration. It should not use H2 data base (the default). |
| magnoliaAuthor.activation.useExistingSecret | bool | `false` | Set this to `true` in case you want to use an existing activation key stored as a secret and provide its name. |
| magnoliaAuthor.bootstrap.instructions | string | `""` | Verbatim content of the instructions for this instance. If empty use a default. This is intended to be used with the --set-file flag of "helm install". |
| magnoliaAuthor.catalinaExtraEnv | object | `{}` | These key/value pairs will be added to CATALINA_OPTS. |
| magnoliaAuthor.contextPath | string | `"/author"` | The context path of this Magnolia instance. Always use a leading slash. |
| magnoliaAuthor.db.backup.enabled | bool | `false` | Enable db backup sidecar. |
| magnoliaAuthor.db.contentsync.address | string | `":9998"` | TLS port of the backup sidecar. |
| magnoliaAuthor.db.jackrabbit.autoRepair | bool | `true` | Errors detected by a consistency check are automatically repaired. If false, errors are only written to the log. |
| magnoliaAuthor.db.jackrabbit.enableConsistencyCheck | bool | `false` | If set to true a consistency check is performed depending on the parameter forceConsistencyCheck. If set to false no consistency check is performed on startup, even if a redo log had been applied. |
| magnoliaAuthor.db.jackrabbit.extraSearchIndexParameters | object | `{}` | Extra search index parameters for jackrabbit configuration (e.g. overwrite search excerpt provider class with `excerptProviderClass`) |
| magnoliaAuthor.db.jackrabbit.forceConsistencyCheck | bool | `false` | Runs a consistency check on every startup. If false, a consistency check is only performed when the search index detects a prior forced shutdown. |
| magnoliaAuthor.db.jackrabbit.onWorkspaceInconsistency | string | `"log"` | If set to log, the process will just log the inconsistency during the re-indexing on startup. If set to fail, the process will fail the re-indexing on startup. |
| magnoliaAuthor.db.persistence.mountPath | string | `"/db"` | Mount point is /db, PGDATA=/db/data |
| magnoliaAuthor.db.persistence.subPath | string | `"data"` | Mount point is /db, PGDATA=/db/data |
| magnoliaAuthor.db.podAnnotations | object | `{}` | Custom annotations added to db pods. |
| magnoliaAuthor.db.restore.bundle_url | string | `"https://s3..."` | URL to backup bundle JSON file to use for restore. |
| magnoliaAuthor.db.restore.enabled | bool | `false` | Enable restore operations. |
| magnoliaAuthor.extraContainers | list | `[]` | Extra sidecar containers added to the Magnolia pod. |
| magnoliaAuthor.extraInitContainers | list | `[]` | Extra init containers added to the Magnolia pod. |
| magnoliaAuthor.jndiResources | list | `[]` | Additional JDNI resources to be added in tomcat's `server.xml`. The key/value pairs will be mapped to xml. |
| magnoliaAuthor.persistence.enabled | bool | `true` | Enable persistence for indexes, cache, tmp files. If this is enabled the MGNL_HOME_DIR env var will be set and a volume will be mounted to the default location unless it's specified here as mountPath. |
| magnoliaAuthor.persistence.existingClaim | string | `nil` | Existing volumes can be mounted into the container. If not specified, helm will create a new PVC. |
| magnoliaAuthor.persistence.size | string | `"10Gi"` | In case of local-path provisioners this is not enforced. |
| magnoliaAuthor.persistence.storageClassName | string | `""` | Empty string means: Use the default storage class. |
| magnoliaAuthor.podAnnotations | object | `{}` | Custom annotations added to pod. |
| magnoliaAuthor.redeploy | bool | `false` | If true, redeploy on "helm upgrade/install" even if no changes were made. |
| magnoliaAuthor.rescueMode | bool | `false` | Enable Groovy rescue console. |
| magnoliaAuthor.resources.limits.memory | string | `"512Mi"` | Maximum amount of memory this pod is allowed to use. This is not the heap size, the heap size is smaller, see `setenv.memory` for details. |
| magnoliaAuthor.resources.requests.memory | string | `"512Mi"` | Minimum amount of memory this pod requests. |
| magnoliaAuthor.setenv.memory.maxPercentage | int | `60` | Maximum amount allocated to heap as a percentage of the pod's resources. |
| magnoliaAuthor.setenv.memory.minPercentage | int | `25` | Minimum amount allocated to heap as a percentage of the pod's resources. |
| magnoliaAuthor.setenv.update.auto | string | `"true"` | Auto-update Magnolia if repositories are empty (usually on the first run). |
| magnoliaAuthor.strategy.type | string | `"Recreate"` | Kubernetes rollout strategy on `helm upgrade ...`. |
| magnoliaAuthor.webarchive.repository | string | `"registry.gitlab.com/mironet/magnolia-demo"` | The docker image where to fetch compiled Magnolia libs from. |
| magnoliaAuthor.webarchive.tag | string | `"latest"` | Do not use 'latest' in production. |
| magnoliaPublic | object | See values below ... | This is the public instance. |
| magnoliaPublic.activation.useExistingSecret | bool | `false` | Set this to `true` in case you want to use an existing activation key stored as a secret and provide its name. |
| magnoliaPublic.bootstrap.instructions | string | `""` | Verbatim content of the instructions for this instance. If empty use a default. This is intended to be used with the --set-file flag of "helm install". |
| magnoliaPublic.catalinaExtraEnv | object | `{}` | These key/value pairs will be added to CATALINA_OPTS. |
| magnoliaPublic.contextPath | string | `"/"` | The context path of this Magnolia instance. Always use a leading slash. |
| magnoliaPublic.db.backup.enabled | bool | `false` | Enable db backup sidecar. |
| magnoliaPublic.db.contentsync.address | string | `":9998"` | TLS port of the backup sidecar. |
| magnoliaPublic.db.contentsync.enabled | bool | `false` | Enable content sync on public instances. Depends on the backup being enabled and configured correctly for pg_wal log shipping. |
| magnoliaPublic.db.jackrabbit.autoRepair | bool | `true` | Errors detected by a consistency check are automatically repaired. If false, errors are only written to the log. |
| magnoliaPublic.db.jackrabbit.enableConsistencyCheck | bool | `false` | If set to true a consistency check is performed depending on the parameter forceConsistencyCheck. If set to false no consistency check is performed on startup, even if a redo log had been applied. |
| magnoliaPublic.db.jackrabbit.extraSearchIndexParameters | object | `{}` | Extra search index parameters for jackrabbit configuration (e.g. overwrite search excerpt provider class with `excerptProviderClass`) |
| magnoliaPublic.db.jackrabbit.forceConsistencyCheck | bool | `false` | Runs a consistency check on every startup. If false, a consistency check is only performed when the search index detects a prior forced shutdown. |
| magnoliaPublic.db.jackrabbit.onWorkspaceInconsistency | string | `"log"` | If set to log, the process will just log the inconsistency during the re-indexing on startup. If set to fail, the process will fail the re-indexing on startup. |
| magnoliaPublic.db.persistence.mountPath | string | `"/db"` | Mount point is /db, PGDATA=/db/data |
| magnoliaPublic.db.persistence.subPath | string | `"data"` | Mount point is /db, PGDATA=/db/data |
| magnoliaPublic.db.restore.bundle_url | string | `"https://s3..."` | URL to backup bundle JSON file to use for restore. |
| magnoliaPublic.db.restore.enabled | bool | `false` | Enable restore operations. |
| magnoliaPublic.extraContainers | list | `[]` | Extra sidecar containers added to the Magnolia pod. |
| magnoliaPublic.extraInitContainers | list | `[]` | Extra init containers added to the Magnolia pod. |
| magnoliaPublic.jndiResources | list | `[]` | Additional JDNI resources to be added in tomcat's `server.xml`. The key/value pairs will be mapped to xml. |
| magnoliaPublic.persistence.enabled | bool | `true` | Enable persistence for indexes, cache, tmp files. If this is enabled the MGNL_HOME_DIR env var will be set and a volume will be mounted to the default location unless it's specified here as mountPath. |
| magnoliaPublic.persistence.existingClaim | string | `nil` | Existing volumes can be mounted into the container. If not specified, helm will create a new PVC. |
| magnoliaPublic.persistence.size | string | `"10Gi"` | In case of local-path provisioners this is not enforced. |
| magnoliaPublic.persistence.storageClassName | string | `""` | Empty string means: Use the default storage class. |
| magnoliaPublic.podAnnotations | object | `{}` | Custom annotations added to pods. |
| magnoliaPublic.redeploy | bool | `true` | If true, redeploy on "helm upgrade/install" even if no changes were made. |
| magnoliaPublic.replicas | int | `1` | How many public instances to deploy. |
| magnoliaPublic.rescueMode | bool | `false` | Enable Groovy rescue console. |
| magnoliaPublic.resources.limits.memory | string | `"512Mi"` | Maximum amount of memory this pod is allowed to use. This is not the heap size, the heap size is smaller, see `setenv.memory` for details. |
| magnoliaPublic.resources.requests.memory | string | `"512Mi"` | Minimum amount of memory this pod requests. |
| magnoliaPublic.setenv.memory.maxPercentage | int | `60` | Maximum amount allocated to heap as a percentage of the pod's resources. |
| magnoliaPublic.setenv.memory.minPercentage | int | `25` | Minimum amount allocated to heap as a percentage of the pod's resources. |
| magnoliaPublic.setenv.update.auto | string | `"true"` | Auto-update Magnolia if repositories are empty (usually on the first run). |
| magnoliaPublic.strategy.type | string | `"Recreate"` | Kubernetes rollout strategy on `helm upgrade ...`. |
| magnoliaPublic.webarchive.repository | string | `"registry.gitlab.com/mironet/magnolia-demo"` | The docker image where to fetch compiled Magnolia libs from. |
| magnoliaPublic.webarchive.tag | string | `"latest"` | Do not use 'latest' in production. |
| metrics.enabled | bool | `true` | Enable JMX exporters. |
| metrics.metricsServerPort | int | `8000` |  |
| metrics.setPrometheusAnnotations | bool | `true` |  |
| nameOverride | string | `""` |  |
| postjob.image | string | `"registry.gitlab.com/mironet/magnolia-bootstrap"` | Where to get the bootstrapper from. This should not be changed under normal circumstances. |
| postjob.imagePullPolicy | string | `"IfNotPresent"` |  |
| postjob.tag | string | `"v0.2.3-rc1"` |  |
| postjob.waitFor | string | `"10m"` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `"None"` |  |
| service.ports[0].name | string | `"http"` |  |
| service.ports[0].port | int | `80` |  |
| service.ports[0].protocol | string | `"TCP"` |  |
| service.ports[0].targetPort | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| sharedDb | object | See values below ... | Shared database (jackrabbit "clustering"). |
| sharedDb.db.contentsync.address | string | `":9998"` | TLS port of the backup sidecar. |
| sharedDb.db.jackrabbit.autoRepair | bool | `true` | Errors detected by a consistency check are automatically repaired. If false, errors are only written to the log. |
| sharedDb.db.jackrabbit.enableConsistencyCheck | bool | `false` | If set to true a consistency check is performed depending on the parameter forceConsistencyCheck. If set to false no consistency check is performed on startup, even if a redo log had been applied. |
| sharedDb.db.jackrabbit.extraSearchIndexParameters | object | `{}` | Extra search index parameters for jackrabbit configuration (e.g. overwrite search excerpt provider class with `excerptProviderClass`) |
| sharedDb.db.jackrabbit.forceConsistencyCheck | bool | `false` | Runs a consistency check on every startup. If false, a consistency check is only performed when the search index detects a prior forced shutdown. |
| sharedDb.db.jackrabbit.onWorkspaceInconsistency | string | `"log"` | If set to log, the process will just log the inconsistency during the re-indexing on startup. If set to fail, the process will fail the re-indexing on startup. |
| sharedDb.db.persistence.subPath | string | `"data"` | Mount point is /db, PGDATA=/db/data |
| sharedDb.db.podAnnotations | object | `{}` | Custom annotations added to db pods. |
| sharedDb.db.restore.bundle_url | string | `"https://s3..."` | URL to backup bundle JSON file to use for restore. |
| sharedDb.db.restore.enabled | bool | `false` | Enable restore operations. |
| sharedDb.enabled | bool | `false` | Enable shared db |
| timezone | string | `"Europe/Zurich"` | Timezone for Magnolia. |

## Configuration

### Application Server

The tomcat setup is derived from the public tomcat helm chart and uses init
containers to copy the actual webapp to the `webapps` folder.

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
    repository: registry.gitlab.com/example/k8s/next-deployment
    tag: latest
  #...
```

The init container is expected to have an already "exploded" webapp in
`/magnolia`. Files in there will be copied into the `webapps` when starting
tomcat.

To pull from a private Docker registry (e.g. GitLab), you have to create a
docker-registry secret:

```bash
kubectl create secret docker-registry gitlab-registry --docker-server=https://registry.gitlab.com --docker-username=<username> --docker-password=<password or token>
```

To use the token from above, specify `pullSecrets` inside `image:` section like
the following:

```yaml
image:
  #...
  pullSecrets:
    - name: gitlab-registry
```

Or you can use service accounts, see [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-image-pull-secret-to-service-account) for details.

### Persistence

In the `magnoliaPublic/Author:` sections of the values you can configure the
Magnolia instances (public and author). This is an example with PostgreSQL as a
backend data base and it's the ony db currently supported.

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

If you like to enable shared database (aka
[Jackrabbit Clustering](https://wiki.magnolia-cms.com/display/WIKI/Setting+up+a+Jackrabbit+Clustering)),
you can configure the shared workspaces and db connection (same as above) like
the following:

```yaml
sharedDb:
  enabled: false
  workspaces:
    - form2db
    - shop
  db: ...
```

### Libraries

If you need additional libraries (jars) you can specify them in the `jars:`
array. This is also how the PostgreSQL JDBC driver is being loaded.

```yaml
  - name: postgres-jdbc
    repository: registry.gitlab.com/mironet/magnolia-jar/postgres-42.2.8
    tag: v0.0.1
    env:
      - name: INIT_DEST
        value: /app/magnolia/WEB-INF/lib
    initScript: /init.sh
```

### Convention expected from init containers

This chart expects the init containers (see the `jars:` array above) to contain
an `/init.sh` script which is called as the only command. As of now the only
tasks expected from init containers is to copy some files to a target directory
specified by the env var `INIT_DEST`.

### Logging

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

Under `loggers` it's possible to define additional loggers with the respective
value.

> **Note:** Do not log to files inside the container. Always log to `stdout` or `stderr` if possible or use a different log shipping mechanism.

### Rescue mode

To enable the
[Groovy Rescue Console](https://documentation.magnolia-cms.com/display/DOCS61/Groovy+module#Groovymodule-RescueApp),
deploy your Helm release with the following flag

for CE projects:
```yaml
magnoliaAuthor:
  rescueMode: true
```
for DX Core projects:
```yaml
magnoliaAuthor:
  rescueModeDX: true
```

This only takes effect if Magnolia is already installed.

## Monitoring / Liveness

As a default, we monitor the public instance via a call to the
[bootstrapper](https://gitlab.com/mironet/magnolia-bootstrap)'s `/readyz` and `/livez`
endpoints.

```yaml
magnoliaPublic:
  #...
  livenessProbe:
    port: 8765 # The default used by the bootstrapper.
    failureThreshold: 4
    initialDelaySeconds: 120
    timeoutSeconds: 10
    periodSeconds: 30
```

Magnolia is not deemed "ready" before the first of the following conditions are met:

- Magnolia itself is reporting a good response to a healthcheck.
- All bootstrap instructions have been executed successfully.

> **Note:** The bootstrap instructions are executed asynchronously after Magnolia itself reports healthy. This allows for a short period of a state during wich not all configuration has been applied but this has proven not to be an issue in production. Having a runtime dependency on it though has been annyoing, hence this is the default behaviour.

## TLS

When run in a Kubernetes environment and `cert-manager` is present you can
prepare an ingress object which should contain all annotations necessary for the
cert manager to issue certificates with eg. Let's Encrypt.

You have to first specify the host names you want certificates for and uncomment
the annotation used by cert-manager to auto-issue certificates from Let's
encrypt:

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

Of course you could still ignore all this and use your own load balancing /
ingress configuration, but this configuration is the one that has been tested.

## Extra sidecar/init containers

Additional sidecar and init containers can be injected in the
`magnoliaAuthor/magnoliaPublic:` sections in the `values.yml`:

```yaml
magnoliaPublic:
  #...
  extraContainers:
    - name: ohhai
      image: nginx:latest
      # ... further configuration according to the k8s containers section syntax.
  extraInitContainers:
    ... # Same syntax as k8s initContainers definition.
```

## Pod Annotations

You can add your own pod annotations for Magnolia deployments with the `podAnnotations` dictionary. Let's say you want to add Prometheus annotations for your pods running Magnolia:

```yaml
magnoliaPublic:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/.monitoring/metrics"
```

## JNDI Resources

You can add additional JNDI resources (usually configured in Tomcat's `server.xml`) by adding the respective XML attribute keys and values. This definition for example ...

```yaml
magnoliaPublic:
  jndiResources:
    - name: "jdbc/custom-postgres"
      auth: "Container"
      type: "javax.sql.DataSource"
      driverClassName: "org.postgresql.Driver"
      url: "jdbc:postgresql://postgres.example.com:5432/database"
      username: "${jndi.postgres.username}"
      password: "${jndi.postgres.password}"
      maxTotal: "20"
      maxIdle: "10"
      maxWaitMillis: "-1"
```

... results in a `server.xml` config section like this:

```xml
<Server port="-1" shutdown="SHUTDOWN">
  <!-- Global JNDI resources
        Documentation at /docs/jndi-resources-howto.html
  -->
  <GlobalNamingResources>
    ...
    <Resource
              auth="Container"
              driverClassName="org.postgresql.Driver"
              maxIdle="10"
              maxTotal="20"
              maxWaitMillis="-1"
              name="jdbc/custom-postgres"
              password="${jndi.postgres.password}"
              type="javax.sql.DataSource"
              url="jdbc:postgresql://postgres.example.com:5432/database"
              username="${jndi.postgres.username}"
              />
  </GlobalNamingResources>
  ...
</Server>
```

> **Note:** Any combination of XML attribute names and values can be used here. They will be copied 1:1 into the target XML structure.

## Expanding `$CATALINA_OPTS`

In the example about JNDI datasources we used variables which can be set by expanding `$CATALINA_OPTS`. This can be done in a declarative way in YAML:

```yaml
magnoliaPublic:
  env:
    - name: JNDI_POSTGRES_USERNAME
      valueFrom:
        secretKeyRef:
          key: postgres.username
          name: jndi
    - name: JNDI_POSTGRES_PASSSWORD
      valueFrom:
        secretKeyRef:
          key: postgres.password
          name: jndi
  catalinaExtraEnv:
    jndi.postgres.username: "${JNDI_POSTGRES_USERNAME}"
    jndi.postgres.password: "${JNDI_POSTGRES_PASSSWORD}"
```

This way we expect a previously existing secret with the username and password for the external database resource.

> **Note**: You could also use the variable name directly, e.g.
> `jndi.postgres.username` but the example here is about showing the declarative
> expansion of `$CATALINA_OPTS`.

## Backups / DB Dumps

The magnolia to object storage backup agent can be used for regular dumps and
backups of the data bases.

### Prerequisites

- S3 bucket with credentials (accesskey and secretkey) **or**
- GCS storage access (key.json file from the Google Console)
- Secret in Kubernetes

### Backup Configuration

You need to set at least the following values according to your environment.
Please have a look at the
[magnolia-backup documentation](https://gitlab.com/mironet/magnolia-backup) for
an explanation of all settings.

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
        - name: MGNLBACKUP_HERITAGE
          value: "my_backup_tag" # Backups will be marked with this tag in object storage.
```

The referenced secret needs to exist before rolling this out. Here's an example
of how to create one:

```bash
# Create files needed for the rest of the example.
echo -n 's3user' > accesskey.txt
 echo -n 'supersecrets3pass' > secretkey.txt

kubectl create secret generic s3-backup-key --from-file=accesskey=./accesskey.txt --from-file=secretkey=./secretkey.txt

rm -f accesskey.txt secretkey.txt
```

(Also see the
[official Kubernetes documentation about secrets](https://kubernetes.io/docs/concepts/configuration/secret/).)

This creates a new sidecar which takes backups every 24h each day. The backups
are streamed directly to S3 without temporarily storing them locally. Because a db dump has proven to be an expensive operation in our tests depending on the size of the database, this method is best suited for smaller (< 1 GiB) databases.

In case of larger data bases (a few GiBs to several TiBs) we recommend to use
[the WAL log shipping method](https://gitlab.com/mironet/magnolia-backup#postgresql-wal-archiving).

### Backup inspection

You can port-forward the backup service and see a list of current backups and
also get direct download links for the S3 server:

```bash
kubectl port-forward <your-release-name>-author-db-0 9999:9999
```

After the port forwarding is established, visit
[http://localhost:9999/list](http://localhost:9999/list) for a list of backups.

## Content Sync

This chart supports spinning up new public instances by synchronizing the database before starting Magnolia resulting in a clone of other (available) public instances.

### Prerequisites

For this to work a few things need to be configured correctly:

- Backup with PG_WAL log shipping method (see [section before](#backups-db-dumps)).
- `cert-manager` needs to be present in the cluster to auto-issue certificates
  for mTLS.

> **Note:** We are working on eliminating the hard requirement for
> `cert-manager`. For now this is the only option.

### Mode of Operation

When spinning up new public databases by setting the `replica: n` value and if
`contentsync.enabled == true`, the new database will try to sync the content
from an already running public database. It will copy the whole database using a
*base backup*. This feature thus only works with PostgreSQL.

After starting the database it is safe to start a new public instance too by
setting `replica: n` of the public `StatefulSet`. It will match the ordinal
number automatically in its database configuration.

The content transfer itself is encrypted and the contentsync server and client
are authenticated by mTLS. There's currently no option to disable this (i.e.
"--insecure" or similar). TLS certificates, CA and client/server certificates,
are auto-generated by `cert-manager` when deployed with helm. `cert-manager` and
its CRDs need to be present in the cluster before using this feature (see
prerequisites above).

Also see the [magnolia-backup documentation](https://gitlab.com/mironet/magnolia-backup) for an explanation of
how this works.

## Activation keypair generation

### Technical background

Magnolia uses a public/private key system for content activation from author to
public instances. If that key is nonexistent on the first boot it will be
generated by Magnolia itself. While this is convenient it makes the application
somewhat stateful. Generating a RSA key out of a passphrase (a secret for
example) is theoretically possible but not easy (nor secure) to do.

### Automatically generated key

This is the easiest approach. A `emptyDir` will be created by the pod and
mounted for the purpose of storing the automatically generated activation key.
You don't have to configure anything for this and it is the default. But use of
this approach is not recommended in production. You can always switch to the
manual secret method below after doing this.

### Secrets

You can specify which secret the pods should be looking for to mount the key
`.properties` file at the correct location. The format of the activation key
file is like follows:

```text
#generated 09.May.2020 04:55 by superuser
#Sat May 09 16:55:03 CEST 2020
key.private=30820277020100300...
key.public=30819F300D06092A8648...
```

You can manually generate it like explained below:

### Direct key input

Magnolia requires RSA keypair properties for the publication mechanism. You can
generate a keypair e.g. with `openssl`.

> **Note:** Magnolia can handle at most 1024 bit key length:

```bash
mkdir temp
openssl genrsa -out temp/key.pem 1024
openssl rsa -in temp/key.pem -pubout -outform DER -out temp/pubkey.der
openssl pkcs8 -topk8 -in temp/key.pem -nocrypt -outform DER -out temp/key.der
```

Now you can create the `activation.properties` secret:

```bash
echo key.public=$(xxd -p temp/key.der | tr -d '\n') > temp/secret.yml
echo key.private=$(xxd -p temp/pubkey.der | tr -d '\n') >> temp/secret.yml
kubectl create secret generic activation-key --from-file=activation-secret=temp/secret.yml
```

The configuration in your `values.yml` should reference this secret so it will
be loaded:

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

This chart is currently used in production. We will adhere to the semver
standard and try to maintain backwards compatiblity within major releases.

## Compatibility

Values used with older chart versions should always work with newer chart versions and provide the same results.

> **Note:** This does not mean a certain deployment will upgrade non-disruptively, i.e. without having to remove it first. See the [Upgrade](#upgrade) section about upgrades in general.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| MiroNet AG | mathias.seiler@mironet.ch | https://www.mironet.ch/ |
| fastforward websolutions | pzingg@fastforward.ch | https://www.fastforward.ch/ |

## Legal Notes

Magnolia, Magnolia Blossom, Magnolia and the Magnolia logo are registered
trademark or trademarks of Magnolia International Ltd.
