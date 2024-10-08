FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

RUN apt update
RUN apt install -y --force-yes \
  libffi-dev \
  libyaml-dev \
  libssl-dev \
  libreadline-dev \
  libjemalloc-dev \
  zlib1g-dev \
  language-pack-ja \
  curl \
  git \
  build-essential \
  libio-socket-ssl-perl \
  apt-transport-https \
  mysql-client \
  libmysqlclient-dev \
  ca-certificates \
  gpg \
  debsig-verify \
  gnupg2 \
  unixodbc \
  unixodbc-dev \
  odbcinst \
  odbcinst1debian2 \
  ruby-dev \
  rbenv

# Setup Mysql ODBC

ENV MYSQL_CONNECTOR_ODBC_VERSION mysql-connector-odbc_8.1.0-1ubuntu22.04_amd64.deb
ENV MYSQL_COMMUNITY_CLIENT_PLUGIN mysql-community-client-plugins_8.0.39-1ubuntu22.04_amd64.deb

RUN curl -sSL -o ${MYSQL_CONNECTOR_ODBC_VERSION} "https://downloads.mysql.com/archives/get/p/10/file/${MYSQL_CONNECTOR_ODBC_VERSION}"
RUN curl -sSL -o ${MYSQL_COMMUNITY_CLIENT_PLUGIN} "https://dev.mysql.com/get/Downloads/MySQL-8.0/${MYSQL_COMMUNITY_CLIENT_PLUGIN}"

RUN dpkg -i ${MYSQL_CONNECTOR_ODBC_VERSION} ${MYSQL_COMMUNITY_CLIENT_PLUGIN}

RUN tee /etc/odbc.ini <<EOF
[MySQL]
Description     = MySQL
Driver          = MySQL ODBC 8.1 Unicode Driver
Database        = ruby_odbc
Server          = mysql
Port            = 3306
EOF

# Setup Ruby

USER vscode

RUN echo 'eval "$(rbenv init -)"' >> /home/vscode/.bashrc

ENV PATH "/home/vscode/.rbenv/bin/:HOME/.rbenv/shims/:$PATH"

RUN mkdir -p /home/vscode/.rbenv/plugins \
  && git clone https://github.com/rbenv/ruby-build.git /home/vscode/.rbenv/plugins/ruby-build

RUN rbenv install 3.3.5
RUN rbenv global 3.3.5