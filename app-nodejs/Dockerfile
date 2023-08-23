# Créditos: https://www.emmanuelgautier.com/blog/snippets/typescript-dockerfile

# Builder
FROM node:18 as builder

WORKDIR /usr/src/app
COPY .yarn ./.yarn
COPY package.json yarn.lock .yarnrc.yml tsconfig.json ./

RUN yarn install
COPY . .

RUN yarn build

# Runtime
FROM node:18-slim

ENV NODE_ENV production

WORKDIR /usr/src/app
COPY .yarn ./.yarn
COPY package.json yarn.lock .yarnrc.yml tsconfig.json ./
RUN yarn install
COPY --from=builder /usr/src/app/dist .

CMD [ "node", "index.js" ]