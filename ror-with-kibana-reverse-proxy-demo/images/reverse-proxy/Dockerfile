# Dockerfile
FROM httpd:2.4

ARG REWRITE_BASE_PATH_BY_KIBANA=please_set_REWRITE_BASE_PATH_BY_KIBANA_arg

# Enable required modules: proxy, balancer, lbmethod, rewrite, headers, slotmem, ssl, wstunnel, socache
RUN sed -i \
    -e 's/^#\(LoadModule slotmem_shm_module modules\/mod_slotmem_shm.so\)/\1/' \
    -e 's/^#\(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_module modules\/mod_proxy.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_http_module modules\/mod_proxy_http.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_wstunnel_module modules\/mod_proxy_wstunnel.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_balancer_module modules\/mod_proxy_balancer.so\)/\1/' \
    -e 's/^#\(LoadModule lbmethod_byrequests_module modules\/mod_lbmethod_byrequests.so\)/\1/' \
    -e 's/^#\(LoadModule rewrite_module modules\/mod_rewrite.so\)/\1/' \
    -e 's/^#\(LoadModule headers_module modules\/mod_headers.so\)/\1/' \
    -e 's/^#\(LoadModule ssl_module modules\/mod_ssl.so\)/\1/' \
    /usr/local/apache2/conf/httpd.conf

RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf \
 && echo "Listen 443" >> /usr/local/apache2/conf/httpd.conf

# Copy vhost and include it
COPY images/reverse-proxy/reverse-proxy-with-rewrite-base-path.conf /tmp/reverse-proxy-with-rewrite-base-path.conf
COPY images/reverse-proxy/reverse-proxy-without-rewrite-base-path.conf /tmp/reverse-proxy-without-rewrite-base-path.conf


RUN mkdir -p /usr/local/apache2/conf/extra \
 && if [ "$REWRITE_BASE_PATH_BY_KIBANA" = "true" ]; then \
      cp /tmp/reverse-proxy-without-rewrite-base-path.conf /usr/local/apache2/conf/extra/reverse-proxy.conf; \
    else \
      cp /tmp/reverse-proxy-with-rewrite-base-path.conf /usr/local/apache2/conf/extra/reverse-proxy.conf; \
    fi \
 && echo "Include conf/extra/reverse-proxy.conf" >> /usr/local/apache2/conf/httpd.conf \
 && rm -f /tmp/reverse-proxy-*.conf

# Copy TLS certs (provide server.crt and server.key under images/reverse-proxy/certs)
COPY conf/reverse-proxy/certs/ /usr/local/apache2/conf/certs/

EXPOSE 80 443
