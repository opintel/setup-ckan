# Build: docker build -t ckan/ckan-base
FROM ubuntu:14.04
# Heavily based on datacats ( https://github.com/datacats/datacats )
MAINTAINER bcessa <ben@pixative.com>

# Configuration variables
ENV CKAN_HOME /usr/lib/ckan
ENV BRANCH release-v2.5.3
ENV INIT_DBS true

# Locale setup
RUN \
  locale-gen en_US.UTF-8 && \
  echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Install dependencies
RUN \
  DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install -y \
    apache2 \
    build-essential \
    curl \
    gdal-bin \
    git-core \
    libapache2-mod-python \
    libapache2-mod-wsgi \
    libcurl4-openssl-dev \
    libgeos-dev \
    libldap2-dev \
    libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    postfix \
    postgresql-client \
    python-dev \
    python-minimal \
    python-virtualenv \
    wget && \
  apt-get clean && \
  apt-get autoclean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" && \
  chmod +x /bin/gosu


# Configure webserver
ADD apache.wsgi /etc/ckan/apache.wsgi
ADD ckan_default.conf /etc/apache2/sites-available/ckan_default.conf
ADD ports.conf /etc/apache2/ports.conf
RUN \
  a2ensite ckan_default && \
  a2dissite 000-default && \
  a2enmod headers && \
  mkdir -p /var/www/storage && \
  chown -R www-data:www-data /var/www/ && \
  usermod -u 1000 -d /var/www/storage www-data

# Install CKAN
RUN \
  virtualenv $CKAN_HOME && \
  mkdir -p $CKAN_HOME /project /var/www/storage && \
  chown -R www-data:www-data /var/www && \
  git clone --depth 1 --branch $BRANCH https://github.com/ckan/ckan /project/ckan && \
  git clone --depth 1 --branch stable https://github.com/ckan/datapusher /project/datapusher && \
  $CKAN_HOME/bin/pip install -U setuptools==18.5 && \
  $CKAN_HOME/bin/pip install -r /project/ckan/requirements.in && \
  $CKAN_HOME/bin/pip install -e /project/ckan && \
  $CKAN_HOME/bin/pip install ckanapi && \
  #$CKAN_HOME/bin/pip install -r /project/datapusher/requirements.txt && \
  # Create sample configuration file
  $CKAN_HOME/bin/paster make-config ckan /project/development.ini && \
  wget -O /project/who.ini https://raw.githubusercontent.com/ckan/ckan/master/ckan/config/who.ini

# HTTP port
EXPOSE 5000

# Entry point
ADD start.sh /start.sh

# User
RUN groupadd -r ckan && useradd -r -g ckan ckan
ENTRYPOINT ["/start.sh"]
