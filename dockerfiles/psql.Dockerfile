FROM alpine:latest
RUN apk --update add postgresql-client

ENTRYPOINT ["psql"]
