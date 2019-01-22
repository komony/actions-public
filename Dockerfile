FROM golang:latest

ADD main.go /go/main.go

RUN apt-get update && \
    apt-get install -y openssl && \
    openssl genrsa -passout pass:x -out /go/server.pass.key 2048 && \
    openssl rsa -passin pass:x -in /go/server.pass.key -out /go/server.key && \
    rm /go/server.pass.key && \
    openssl req -new -key /go/server.key -out /go/server.csr \
        -subj "/C=US/ST=Virginia/L=Fairfax/O=OrgName/OU=IT/CN=example.com" && \
    openssl x509 -req -days 365 -in /go/server.csr -signkey /go/server.key -out /go/server.crt

RUN sed 's/CLOUD_PROVIDER/Heroku/' /go/main.go > /go/heroku.go

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-s -w' /go/heroku.go

CMD [ "/go/heroku" ]

# https server listens on port 8080.
EXPOSE 443
