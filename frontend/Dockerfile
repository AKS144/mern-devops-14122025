FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
# Clean install (forces fresh download and correct permissions)
RUN npm ci --legacy-peer-deps || npm install

# Copy source code
COPY . .

# Fix permissions manually just in case
RUN chmod +x node_modules/.bin/react-scripts

# Build
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN echo 'server { listen 80; location / { root /usr/share/nginx/html; index index.html; try_files $uri /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
