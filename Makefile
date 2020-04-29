
IMAGE := media_server
NGINX_STATIC_PATH := $(NGINX_STATIC_PATH)
ifneq (NGINX_STATIC_PATH,)
	NGINX_STATIC_VOLUME := -v "$(NGINX_STATIC_PATH)":/var/www/static:ro
endif

nginx: nginx_build
	docker run \
		--rm -it \
		--name $@ \
		-p 1935:1935 \
		-p 8000:8000 \
		$(IMAGE)

nginx_static: nginx_build
	docker run \
		--rm -it \
		--name $@ \
		$(NGINX_STATIC_VOLUME) \
		-p 1935:1935 \
		-p 8000:8000 \
		$(IMAGE) \
		static.sh

server_dlna: nginx_build
	docker run \
		--rm -it \
		--name $@ \
		$(NGINX_STATIC_VOLUME) \
		-p 8200:8200 \
		$(IMAGE) \
		dlna.sh

nginx_build:
	docker build -t $(IMAGE) .

