FROM fluent/fluentd:v1.3.3-onbuild-1.0

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && gem install \
        fluent-plugin-elasticsearch \
 && gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

USER fluent

