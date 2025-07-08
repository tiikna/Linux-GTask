FROM nginx:latest

# Copy custom HTML to nginx default html folder
COPY html /usr/share/nginx/html
