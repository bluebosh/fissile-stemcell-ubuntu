ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Install RVM & Ruby 2.3.1
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
        && curl -sSL https://raw.githubusercontent.com/rvm/rvm/stable/binscripts/rvm-installer | bash -s stable --ruby=2.3.1 \
        && /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install bundler '--version=1.11.2' --no-format-executable" \
        && echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

# Install dumb-init
ARG DUMB_INIT_VER=1.2.1
RUN curl -L "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64" -o /usr/bin/dumb-init && chmod a+x /usr/bin/dumb-init

# Install configgin
ARG CONFIGGIN_VER=0.14.0
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install configgin ${CONFIGGIN_VER:+--version=${CONFIGGIN_VER}}"

# Configure logrotate
RUN /bin/bash -c "mv /etc/cron.daily/logrotate /usr/bin/logrotate-cron && echo '0,15,30,45 * * * * root /usr/bin/logrotate-cron' > /etc/cron.d/logrotate"

# Add additional configuration and scripts
ADD monitrc.erb /opt/fissile/monitrc.erb

ADD post-start.sh /opt/fissile/post-start.sh
RUN chmod ug+x /opt/fissile/post-start.sh

ADD rsyslog_conf/etc /etc/

# Generate stemcell version file /etc/stemcell_version
ARG UBUNTU_VER
RUN curl -L "https://bcf-stemcell-ubuntu.s3.amazonaws.com/bcf-stemcell-ubuntu-${UBUNTU_VER}-version" -o /etc/stemcell_version