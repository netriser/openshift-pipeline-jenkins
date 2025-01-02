FROM registry.redhat.io/nginx-118/nginx:1-118.0

# Configurations supplémentaires (ajuster les permissions, ajouter des fichiers, etc.)
RUN mkdir -p /tmp/nginx/cache/client_temp && \
    chmod -R 777 /tmp/nginx/cache && \
    chown -R 1001:0 /tmp/nginx/cache

# Exemple de copie d'un fichier HTML dans le conteneur
COPY index.html /usr/share/nginx/html/index.html

# Passer à un utilisateur non-root
USER 1001

# Exposer les ports
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
