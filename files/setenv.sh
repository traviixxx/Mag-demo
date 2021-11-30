CLASSPATH="${EXTRA_LIBS}/*"

CATALINA_OPTS="$CATALINA_OPTS \
 -server \
 -Djava.awt.headless=true \
 -Djava.security.egd=file:/dev/./urandom \
 -Dfile.encoding=UTF-8 \
 -Dsun.jnu.encoding=UTF-8 \
 -Duser.timezone={{ .Values.timezone }} \
 -XX:+UseContainerSupport \
 -XX:MinRAMPercentage=${JVM_RAM_MIN_PERCENTAGE:-25} \
 -XX:MaxRAMPercentage=${JVM_RAM_MAX_PERCENTAGE:-80} \
 -XX:+UseG1GC \
 -XX:+UseStringDeduplication \
 -XX:G1ReservePercent=10 \
 -XX:ThreadStackSize=512k \
 -XX:+ExitOnOutOfMemoryError \
{{- if .Values.metrics.enabled }}
 -javaagent:${EXTRA_LIBS}/jmx_prometheus_javaagent.jar={{ $.Values.metrics.metricsServerPort }}:/jmxexporter/config.yml \
{{- end }}
 -XshowSettings:vm"

# -XX:+PrintFlagsFinal \

# Magnolia settings
CATALINA_OPTS="$CATALINA_OPTS \
 -Dmagnolia.repositories.jackrabbit.config=WEB-INF/config/repo-conf/jackrabbit.xml \
 -Dmagnolia.bootstrap.authorInstance=${MGNL_AUTHOR_INSTANCE:-true} \
 -Dmagnolia.develop=${MGNL_DEVELOPER_MODE:-false} \
 -Dmagnolia.update.auto=${MGNL_AUTO_UPDATE:-true} \
 -Dmagnolia.ui.sticker.color=${MGNL_UI_STICKER_COLOR:-blue} \
{{- if eq .magnoliaMode "author" }}
 -Dmagnolia.author.key.location={{ .values.activation.keyLocation }} \
{{- end }}
 -Dmagnolia.home=${MGNL_HOME_DIR:-/mgnl-home} \
 -Dmagnolia.repositories.home=${MGNL_REPOSITORIES_HOME:-\$\{magnolia.home\}/repositories} \
 -Dmagnolia.resources.dir=${MGNL_RESOURCES_DIR:-\$\{magnolia.home\}/modules}"

{{ if .Values.sharedDb.enabled -}}
CATALINA_OPTS="$CATALINA_OPTS \
 -Dmagnolia.repositories.jackrabbit.cluster.config=WEB-INF/config/repo-conf/jackrabbit-shared.xml \
{{- if eq .magnoliaMode "author" }}
 -Dmagnolia.repositories.jackrabbit.cluster.master=true \
{{- else }}
 -Dmagnolia.repositories.jackrabbit.cluster.master=false \
{{- end }}
 -Dmagnolia.clusterid=cid_${HOSTNAME}"
{{- end }}

{{- with .values.catalinaExtraEnv }}
{{ $list := list }}
CATALINA_OPTS="$CATALINA_OPTS \
{{ range $key, $value := . -}}
{{ $list = append $list (printf "-D%s=%s" $key $value) -}}
{{- end -}}
{{ $list | join " \\\n" | indent 1 }}"
{{- end }}

CATALINA_OPTS="$CATALINA_OPTS $CATALINA_OPTS_EXTRA"
