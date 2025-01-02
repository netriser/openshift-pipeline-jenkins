FROM nginx:alpine

# Modifier le port d'écoute pour qu'il soit non privilégié (supérieur à 1024)
RUN sed -i 's/listen 80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# Ajouter le fichier HTML
COPY index.html /usr/share/nginx/html/index.html

# Ajuster les permissions des répertoires requis par Nginx
RUN mkdir -p /var/cache/nginx /var/run/nginx && \
    chown -R 1001:0 /var/cache/nginx /var/run/nginx && \
    chmod -R g=u /var/cache/nginx /var/run/nginx

# Utiliser un utilisateur non-root
USER 1001

# Exposer le nouveau port
EXPOSE 8080

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
