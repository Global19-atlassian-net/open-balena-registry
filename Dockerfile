FROM resin/resin-base:1

EXPOSE 80

# We need features from an up to date (1.9+) nginx so we use their repository
RUN echo 'deb http://nginx.org/packages/mainline/debian/ jessie nginx' > /etc/apt/sources.list.d/nginx.list

RUN apt-get -q update \
	&& apt-get install -y \
		apache2-utils \
		ca-certificates \
		librados2 \
		nginx \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm /etc/nginx/conf.d/default.conf \
	&& ln -s /usr/src/app/nginx.conf /etc/nginx/conf.d/docker_registry.conf

ENV REGISTRY_VERSION 2.3.1
ENV REGISTRY_BINARY_COMMIT d7b2c405ae6b67b39460d57231f67731fe232819
ENV REGISTRY_BINARY_URL https://github.com/docker/distribution-library-image/raw/${REGISTRY_BINARY_COMMIT}/registry/registry

RUN wget -O /usr/local/bin/docker-registry ${REGISTRY_BINARY_URL} \
	&& chmod a+x /usr/local/bin/docker-registry

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable resin-registry.service
