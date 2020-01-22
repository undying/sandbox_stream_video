
NGINX_IMAGE := rtmp_nginx
NGINX_STATIC_PATH := $(NGINX_STATIC_PATH)
ifneq (NGINX_STATIC_PATH,)
	NGINX_STATIC_VOLUME := -v "$(NGINX_STATIC_PATH)":/var/www/static:ro
endif

nginx: nginx_build
	docker run \
		--rm -it \
		--name $(NGINX_IMAGE) \
		-p 1935:1935 \
		-p 8000:8000 \
		$(NGINX_IMAGE)

nginx_static: nginx_build
	docker run \
		--rm -it \
		--name $(NGINX_IMAGE) \
		$(NGINX_STATIC_VOLUME) \
		-p 1935:1935 \
		-p 8000:8000 \
		$(NGINX_IMAGE)

nginx_build:
	docker build -t $(NGINX_IMAGE) .

nginx_exec:
	docker exec -it $(NGINX_IMAGE) bash

