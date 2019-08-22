ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG RHN_USERNAME
ARG RHN_PASSWORD
RUN subscription-manager register --username $RHN_USERNAME --password $RHN_PASSWORD
RUN subscription-manager attach --auto
RUN rpm --rebuilddb; yum install -y yum-plugin-ovl

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB\
        && curl -sSL https://raw.githubusercontent.com/rvm/rvm/stable/binscripts/rvm-installer | bash -s stable --ruby=2.4.0 \
        && /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install bundler '--version=1.11.2' --no-format-executable" \
        && echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

RUN curl -L "https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64" -o /usr/bin/dumb-init && chmod a+x /usr/bin/dumb-init

RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install configgin -v 0.18.4"

# RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm
RUN yum update
RUN yum install -y python36.x86_64 perl-Pod-Checker jq.x86_64

RUN yum erase -y openssh.x86_64

# Configure logrotate
# RUN /bin/bash -c "mv /etc/cron.daily/logrotate /usr/bin/logrotate-cron && echo '0,15,30,45 * * * * root /usr/bin/logrotate-cron' > /etc/cron.d/logrotate"

# Add additional configuration and scripts
RUN mkdir -p /opt/fissile
ADD monitrc.erb /opt/fissile/monitrc.erb

ADD post-start.sh /opt/fissile/post-start.sh
RUN chmod ug+x /opt/fissile/post-start.sh

ADD rsyslog_conf/etc /etc/

RUN ln -sf /usr/sbin/crond /usr/sbin/cron
RUN ln -sf /usr/lib64/libstdc++.so.6.0.19 /usr/lib64/libstdc++.so

ADD assets/libstdc++.a /usr/lib/gcc/x86_64-redhat-linux/4.8.2/
