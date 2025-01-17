FROM nginx:alpine
#FROM nginx:1.26.0-alpine
# Modifier le port d'écoute pour qu'il soit non privilégié (supérieur à 1024)
#RUN sed -i 's/listen 80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# Ajouter le fichier HTML
COPY index.html /usr/share/nginx/html/index.html

# 1. support running as arbitrary user which belogs to the root group
# 2. users are not allowed to listen on priviliged ports
# 3. comment user directive as master process is run as user in OpenShift anyhow
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx && \
    chgrp -R root /var/cache/nginx && \
    sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf && \
    addgroup nginx root

EXPOSE 8081

USER nginx