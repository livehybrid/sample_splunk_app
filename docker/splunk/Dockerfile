ARG SPLUNK_VERSION=latest
FROM splunk/splunk:$SPLUNK_VERSION

COPY docker/splunk/server.conf /opt/splunk/etc/system/local/server.conf
COPY docker/splunk/ui-prefs.conf /opt/splunk/etc/system/local/ui-prefs.conf
COPY docker/splunk/splunk-launch.conf /opt/splunk/etc/splunk-launch.conf
COPY docker/splunk/authorize.conf /opt/splunk/etc/system/local/authorize.conf

COPY _submodules/addonfactory_test_matrix_splunk/packages/all/ /opt/splunk/etc/apps/
COPY _submodules/0_cicd_base /opt/splunk/etc/apps/0_cicd_base

USER root
ARG HOST_UID=1000
ARG HOST_GID=1000
# do the user/group hokey kokey to make splunk match the host user/group
RUN echo $HOST_UID; echo $HOST_GID; usermod -u $HOST_UID splunk && \
    if getent group $HOST_GID; then \
        if getent group $HOST_GID | grep -v splunk; then \
            sudo groupmod -g 1013 $(getent group $HOST_GID | cut -d':' -f1); \
        fi; \
    fi \
    && groupmod -g $HOST_GID splunk

USER ${ANSIBLE_USER}
