# Stage 1: Build
FROM node:18 AS builder

WORKDIR /usr/app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm install

COPY ./src ./src
RUN npm run build

# Remove unnecessary dependencies
RUN curl -sfL https://gobinaries.com/tj/node-prune | sh && node-prune

# Stage 2: Production
FROM gcr.io/distroless/nodejs18-debian11 AS runner

WORKDIR /usr/app 

COPY --from=builder /usr/app/dist ./dist
COPY --from=builder /usr/app/node_modules ./node_modules
COPY --from=builder /usr/app/package.json ./package.json

EXPOSE 3000
CMD ["dist/server.js"]

# docker build -t express-api-prod .
# docker run -p 3000:3000 express-api-prod