FROM golang:1.21.3 as builder
ARG SERVICE_NAME
WORKDIR /src
COPY . .
RUN go build  -v -o /bundle ./cmd/${SERVICE_NAME}/...

FROM debian
RUN apt update && apt install -y ca-certificates && update-ca-certificates
COPY --from=builder /bundle /bundle
CMD ["/bundle"]
