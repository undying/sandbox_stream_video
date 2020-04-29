
FROM ubuntu:18.04
CMD [ "/sbin/init.sh" ]

ENV DEBIAN_FRONTEND=noninteractive
ENV mod_pdf_path=/opt/mod_pdf

ENV deps_build="\
  gdb valgrind \
  wget \
  build-essential \
  "
ENV deps_runtime="\
  ca-certificates \
  "

ENV deps_runtime_dlna="minidlna"

ENV deps_build_nginx="\
  libgeoip-dev \
  zlib1g-dev \
  libssl-dev \
  libpcre3-dev \
  "
ENV deps_runtime_nginx="\
  geoip-bin \
  zlib1g \
  "

ENV nginx_v=1.17.7
ENV rtmp_v=1.2.1 rtmp_path=/opt/nginx-rtmp-module
ENV mpegts_v=0.1.1 mpegts_path=/opt/nginx-ts-module

RUN set -x \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    ${deps_build} \
    ${deps_runtime} \
    ${deps_runtime_dlna} \
    ${deps_build_nginx} \
    ${deps_runtime_nginx}

RUN set -x \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
  && export CODENAME=$(awk -F'=' '/CODENAME/ {print $2;exit}' /etc/os-release) \
  && cd /opt/ \
  && printf "\
		https://github.com/arut/nginx-rtmp-module/archive/v${rtmp_v}.tar.gz\n \ 
    https://github.com/arut/nginx-ts-module/archive/v${mpegts_v}.tar.gz\n \
    https://nginx.org/download/nginx-${nginx_v}.tar.gz" \
    |xargs -L1 -P${CPU_COUNT} -I{} wget --quiet {} \
  && ls *.gz|xargs -L1 -P${CPU_COUNT} -I{} tar -xzf {} \
  && rm -rfv *.gz

RUN set -x \
  && ln -s /opt/nginx-rtmp-module-${rtmp_v} ${rtmp_path} \
  && ln -s /opt/nginx-ts-module-${mpegts_v} ${mpegts_path}

RUN set -x \
  && echo "building nginx" \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
  && cd /opt/nginx-${nginx_v} \
  && ./configure \
    --with-debug \
    --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    \
    --user=nginx --group=nginx \
    \
    --with-cc-opt="-O0 -g -ggdb" \
    \
    --with-threads \
    --with-pcre-jit \
    --with-file-aio \
    \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_geoip_module \
    --with-http_realip_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    \
    --without-http_ssi_module \
    --without-http_scgi_module \
    --without-http_uwsgi_module \
    --without-http_mirror_module \
    --without-http_fastcgi_module \
    --without-http_memcached_module \
    \
    --add-module="${rtmp_path}" \
    --add-module="${mpegts_path}" \
    \
    && make -j${CPU_COUNT} \
    && make install \
    \
    && useradd --user-group --system nginx \
    \
    && install -d -o nginx -g nginx /var/cache/nginx/ \
    && install -d -o nginx -g nginx /etc/nginx/ /var/www/ \
    && install -o nginx conf/mime.types /etc/nginx/ \
    && install -o nginx html/* /var/www/ \
    && nginx -V

RUN set -x \
  && for i in rtmp ts/hls ts/dash;do \
    install -d -o nginx -g nginx /var/www/${i}; \
  done

COPY root/ /

