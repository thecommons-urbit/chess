# syntax=docker/dockerfile:1

FROM node:18.4
# An environment variable made popular by the express web server framework which
# checks the value when Node is run and may take different actions. The typical
# values are 'dev' and 'prod'.
ENV NODE_ENV=prod

# Copy files from source
WORKDIR /app
COPY ["src/frontend/", "./frontend/"]

# Build frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run-script lint
RUN npm run-script build

# Copy output files
RUN mkdir output
RUN cp -rfL html/index.html css js output/

# Assumes that some local dir is mounted as a volume at /app/output
# (e.g. the way ./bin/build.sh calls 'docker run')
WORKDIR /app
CMD cp -rfL frontend/output/* output/
