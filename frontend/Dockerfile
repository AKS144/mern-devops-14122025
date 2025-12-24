FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV DISABLE_ESLINT_PLUGIN=true
RUN npx react-scripts build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

# Remove default config and copy our custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
