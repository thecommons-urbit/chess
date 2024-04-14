# syntax=docker/dockerfile:1

FROM node:slim
# An environment variable made popular by the express web server framework which
# checks the value when Node is run and may take different actions. The typical
# values are 'dev' and 'prod'.
ENV NODE_ENV=prod

WORKDIR /app/frontend

# Install dependencies
COPY ["src/frontend/package.json", "./"]
RUN npm install --verbose

# Copy files from source
COPY ["src/frontend/", "./"]
RUN rm package-lock.json

# Build frontend
RUN npm run-script lint
RUN npm run-script build

# Copy output files
RUN mkdir output
RUN cp -rfL ../../build/frontend/* output/

# Assumes that some local dir is mounted as a volume at /app/output
# (e.g. the way ./bin/build.sh calls 'docker run')
WORKDIR /app
CMD cp -rfL frontend/output/* output/
