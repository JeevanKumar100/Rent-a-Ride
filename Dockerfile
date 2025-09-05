# build stage
FROM node:18-alpine AS build
WORKDIR /app
# copy package files first to leverage cache
COPY package*.json ./
RUN npm ci --silent
COPY . .
RUN npm run build

# final stage: serve with nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
# optional: add a custom nginx conf that falls back to index.html (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
