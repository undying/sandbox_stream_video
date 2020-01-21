
NGINX_IMAGE = rtmp_nginx
VIDEO_PATH = "/home/kron/Videos/Vinland Saga - AniLibria.TV [WEBRip 1080p]"

nginx: nginx_build
	docker run \
		--rm -it \
		--name $(NGINX_IMAGE) \
		-v $(PWD)/root/etc/nginx:/etc/nginx \
		-p 1935:1935 \
		-p 8000:8000 \
		$(NGINX_IMAGE)

nginx_build:
	docker build -t $(NGINX_IMAGE) .

nginx_exec:
	docker exec -it $(NGINX_IMAGE) bash
