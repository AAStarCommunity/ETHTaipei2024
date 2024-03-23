# EthPaymaster-Back
EthPaymaster relay Back-end Service

Basic flow :
![](https://raw.githubusercontent.com/jhfnetboy/MarkDownImg/main/img/202403052039293.png)


# Quick Start

## 1. Swagger

### 1.1 install

```shell
go install github.com/swaggo/swag/cmd/swag@latest
```

### 1.2 init swag

```shell
swag init -g ./cmd/server/main.go
```

> FAQ: [Unknown LeftDelim and RightDelim in swag.Spec](https://github.com/swaggo/swag/issues/1568)

## 2. Run

```shell
go mod tidy
go run ./cmd/server/main.go
```


## 3. Docker

> build image named `relay:demo`

```shell
docker build -t relay:demo .
```

> run image

```shell
 docker run --rm -e Env=dev -e jwt__idkey=id -e jwt__realm=aastar -e jwt__security=security -p 80:80 relay:demo
```

this will create a container named relay using image relay:demo, and will destroy after stop the container;

`Env` means running environment, `dev` supports much more details for debugging, others equal to `prod`

`jwt__*` is for JWT auth

when you're running your container, open browser with [swagger](http://localhost/swagger/index.html)

