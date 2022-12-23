FROM webdevops/php-nginx:8.1-alpine AS base
LABEL maintainer="Linh Phan <linh.phan@codecomplete.com>"

ENV WEB_DOCUMENT_ROOT=/app/public
ENV PHP_DISMOD=bz2,calendar,exiif,ffi,intl,gettext,ldap,mysqli,imap,pgsql,soap,sockets,sysvmsg,sysvsm,sysvshm,shmop,xsl,apcu,vips,yaml,imagick,mongodb,amqp

WORKDIR /app

# Install WinterCMS
ARG CMS_VERSION=1.2.1
RUN composer create-project wintercms/winter . "${OCTOBER_VERSION}"

# SQLite db
RUN touch ./storage/database.sqlite

# Overwrite docker
COPY docker/overwrite/ /

ENV COMPOSER_ALLOW_SUPERUSER=1

# Remove demo paths
# RUN rm -rf ./plugins/winter/demo
# RUN rm -rf ./themes/demo

# Copy source
COPY src/.env ./.env
COPY src/plugins ./plugins

### Target: Develoment
FROM base AS development

ENV WEB_DOCUMENT_ROOT=/app
# Install plugins
RUN composer require winter/wn-builder-plugin

RUN chown -R application:application .

### Target: Production
FROM base AS production

ENV WEB_DOCUMENT_ROOT=/app/public
# Using public folder for ultimate security
RUN php artisan winter:mirror public/
RUN chown -R application:application .
