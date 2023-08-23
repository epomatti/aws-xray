# Créditos: https://www.emmanuelgautier.com/blog/snippets/typescript-dockerfile

# Builder
FROM node:18 as builder

WORKDIR /usr/src/app
COPY .yarn ./.yarn
COPY package.json yarn.lock .yarnrc.yml ./

# RUN yarn set version 3.x
RUN yarn install --frozen-lockfile
COPY . .

RUN yarn build

# Runtime
FROM node:18-slim

ENV NODE_ENV production

WORKDIR /usr/src/app

COPY .yarn ./.yarn
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --frozen-lockfile
COPY --from=builder /usr/src/app/dist ./dist

CMD [ "node", "dist/index.js" ]