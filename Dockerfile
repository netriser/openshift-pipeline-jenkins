FROM nginx:alpine

RUN mkdir -p /var/run/nginx /var/log/nginx /var/cache/nginx && \
	chown -R nginx:0 /var/run/nginx /var/log/nginx /var/cache/nginx && \
	chmod -R g=u /var/run/nginx /var/log/nginx /var/cache/nginx

COPY index.html /usr/share/nginx/html/index.html

USER nginx:nginx
EXPOSE 80

CMD ["nginx","-g","daemon off;"]