FROM alpine:3.9

WORKDIR /app
COPY . /app

RUN apk --no-cache --update add \
        build-base \
        gcc \
        musl-dev \
        python3 \
        python3-dev \
    && python3 -m ensurepip \
    && pip3 install --no-cache-dir --upgrade \
        pip \
        setuptools \
    && pip3 install --no-cache-dir -r /app/requirements.txt \
    && apk del \
        build-base \
        python3-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
