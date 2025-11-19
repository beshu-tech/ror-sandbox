FROM node:20-bookworm-slim

WORKDIR /example-app
COPY app.js .

RUN npm init -y \
 && npm i --omit=dev elastic-apm-node express \
 && apt-get update \
 && apt-get install -y curl jq net-tools netcat-traditional

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "app.js"]