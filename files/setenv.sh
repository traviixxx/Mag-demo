CLASSPATH="${CATALINA_BASE}/lib2/*"

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
 -Dmagnolia.resources.dir=${MGNL_RESOURCES_DIR:-\$\{magnolia.home\}/modules}"

{{ if .Values.sharedDb.enabled -}}
CATALINA_OPTS="$CATALINA_OPTS \
 -Dmagnolia.repositories.jackrabbit.cluster.config=WEB-INF/config/repo-conf/jackrabbit-shared.xml \
 -Dmagnolia.repositories.jackrabbit.cluster.master={{ eq .magnoliaMode "public" | ternary "true" "false" }} \
 -Dmagnolia.clusterid=cid_{{ .magnoliaMode }}"
{{- end }}

CATALINA_OPTS="$CATALINA_OPTS $CATALINA_OPTS_EXTRA"
