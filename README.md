# magnolia-helm

Helm Chart for Magnolia CMS.

This chart deploys a Magnolia CMS instance (author or public) and if desired
configures it to use a data base for its backend storage.

> **NOTE:** This chart just deploys **one single** instance of Magnolia. Usually you want
two instances, an author and a public instance.

## Configuration

The tomcat setup is derived from the public tomcat helm chart and uses init
containers the copy the actual webapp to the `webapps` folder.

You can specify the tomcat image and tag in the values:

```yaml
image:
  #...
  tomcat:
    repository: tomcat
    tag: "9-jre11-slim"
```

The actual webapp is specified here:

```yaml
image:
  webarchive:
    repository: registry.gitlab.com/mathias.seiler/magnolia-demo
    tag: latest
```

The init container is expected to have an already "exploded" webapp in
`/magnolia`. Files in there will be copied into the `webapps` when starting tomcat.

In the `magnolia:` section of the values you can configure the Magnolia instance
itself. This is an example with PostgreSQL as a backend data base and it's the default.

```yaml
magnolia:
  author: True
  repository:
    type: postgres
```

You can configure the data base specifics here:

```yaml
db:
  repository: postgres
  tag: 11.5-alpine
  type: postgres
  name: author
```

If you need additional libraries (jars) you can specify them in the `jars:`
array.

### Convention expected from init containers

This chart expects the init container to contain an `/init.sh` script which is
called as the only command. As of now the only tasks expected from init
containers is to copy some files to a target directory specified by the env var
`INIT_DEST`.

## TLS

When run in a Kubernetes environment we expect `cert-manager` to be present and
the ingress object should contain all annotations necessary for the cert manager
to issue certificates with Let's Encrypt.


### Config Maps

`magnolia.properties` and a corresponding XML file for the persistence layer is
generated and stored as a ConfigMap. It will be mounted in the container when run.
