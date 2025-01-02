FROM nginx:stable
RUN mkdir -p /var/cache/nginx/client_temp && \
    chmod -R 777 /var/cache/nginx && \
    chown -R 1001:0 /var/cache/nginx
USER 1001
COPY . /usr/share/nginx/html
