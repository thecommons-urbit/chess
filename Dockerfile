# syntax=docker/dockerfile:1

FROM node:18.4.0
# An environment variable made popular by the express web server framework which
# checks the value when Node is run and may take different actions. The typical
# values are 'dev' and 'prod'.
#ENV NODE_ENV=prod
ENV NODE_ENV=dev
WORKDIR /app

COPY ["src/frontend/", "./frontend/"]
WORKDIR /app/frontend
RUN npm install
RUN npm test
RUN npm run-script build

WORKDIR /app
# Assumes that some local dir is mounted as a volume at /app/output
CMD cp -rfL frontend/* output/
