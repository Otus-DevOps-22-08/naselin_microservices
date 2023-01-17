FROM fluent/fluentd:v0.12

RUN    gem install faraday --no-rdoc --no-ri --version 1.10.2 \
    && gem install faraday-net_http --no-rdoc --no-ri --version 2.1.0 \
    && gem install elasticsearch --no-rdoc --no-ri --version 7.4.0 \
    && gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5 \
    && gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
COPY fluent.conf /fluentd/etc
