# syntax=docker/dockerfile:1

FROM node:16.10.0
# An environment variable made popular by the express web server framework which
# checks the value when Node is run and may take different actions. The typical
# values are 'dev' and 'prod'.
ENV NODE_ENV=dev
WORKDIR /app

# TODO: update package-lock in JSON
#COPY ["package.json", "package-lock.json", "tsconfig.json", "webpack.config.js", "./"]]
COPY ["package.json", "tsconfig.json", "webpack.config.js", "./"]]

RUN npm install

COPY ["src/frontend/", "./src/frontend/"]

#CMD npm run build
RUN npm run build

CMD cp -r ./node_modules ./src/frontend/

