# nginx/Dockerfile
FROM nginx:alpine

# Supprimer la configuration par défaut
RUN rm /etc/nginx/nginx.conf

# Copier notre configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443 3000

CMD ["nginx", "-g", "daemon off;"]