CLASSPATH="${CATALINA_BASE}/lib2/*"

CATALINA_OPTS="$CATALINA_OPTS \
 -server \
 -Djava.awt.headless=true \
 -Djava.security.egd=file:/dev/./urandom \
 -Dfile.encoding=UTF-8 \
 -Dsun.jnu.encoding=UTF-8
 -XX:+UseContainerSupport \
 -XX:MinRAMPercentage=${JVM_RAM_MIN_PERCENTAGE:-25} \
 -XX:MaxRAMPercentage=${JVM_RAM_MAX_PERCENTAGE:-80} \
 -XX:ThreadStackSize=512k \
 -XX:+ExitOnOutOfMemoryError \
 -XshowSettings:vm"

# -XX:+PrintFlagsFinal \

# Magnolia settings
CATALINA_OPTS="$CATALINA_OPTS \
 -Dmagnolia.develop=${MGNL_DEVELOPER_MODE:-false} \
 -Dmagnolia.bootstrap.authorInstance=${MGNL_AUTHOR_INSTANCE:-true} \
 -Dmagnolia.repositories.jackrabbit.config=WEB-INF/config/repo-conf/jackrabbit.xml \
 -Dmagnolia.update.auto=${MGNL_AUTO_UPDATE:-true}"
#  -Dmagnolia.ui.sticker.environment=${MGNL_UI_STICKER_ENV:-} \
#  -Dmagnolia.ui.sticker.color=${MGNL_UI_STICKER_COLOR:-red}"

CATALINA_OPTS="$CATALINA_OPTS $CATALINA_OPTS_EXTRA"