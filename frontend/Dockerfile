FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
# Use npm install to ensure compatibility
RUN npm install

# Copy source code
COPY . .

# Use NPX to run build (More robust path handling)
RUN npx react-scripts build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN echo 'server { listen 80; location / { root /usr/share/nginx/html; index index.html; try_files $uri /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
