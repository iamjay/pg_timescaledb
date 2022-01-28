FROM pathompong/postgres:11.14-alpine-namelen128

RUN apk add make cmake gcc musl-dev openssl openssl-dev
COPY build-tms.sh /build-tms.sh
RUN /build-tms.sh 11.14 1.7.2,1.7.4

