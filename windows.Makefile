# business data model manager system

# 参考
# 在 Golang 中开发中使用 Makefile
# https://studygolang.com/articles/11131

# Golang的跨平台编译程序
# https://www.cnblogs.com/ghj1976/archive/2013/04/19/3030703.html
#各平台的GOOS和GOARCH参考
#OS                   ARCH                          OS version
#linux                386 / amd64 / arm             >= Linux 2.6
#darwin               386 / amd64                   OS X (Snow Leopard + Lion)
#freebsd              386 / amd64                   >= FreeBSD 7
#windows              386 / amd64                   >= Windows 2000

# Golang 编译Mac、Linux、Windows多平台可执行程序
# https://studygolang.com/articles/28339?fr=sidebar

# Docker命令_各种参数简介（run、v、rm、-w、-u、-e）
# https://blog.csdn.net/sxzlc/article/details/107676425

# Makefile 入门
# https://zhuanlan.zhihu.com/p/149346441

# 使用xgo编译支持CGO

# 定义make变量
GO=go
GOBUILD=$(GO) build
GOCLEAN=$(GO) clean
GOTEST=$(GO) test
BINARY_PATH=./bin
CMD_BINARY_NAME=$(BINARY_PATH)/business_data_model
CMD_BINARY_UNIX=$(CMD_BINARY_NAME)_unix

# make 不指定动作时，默认执行第一个动作
default:build

# 定义build，test，clean，run，deps动作 和build-linux， docker-build动作
test:
	$(GOTEST) -v
clean:
	$(GOCLEAN)
#	rm -f $(CMD_BINARY_NAME)
#	rm -f $(CMD_BINARY_UNIX)
	rm -f $(BINARY_PATH)/*

mod:
	$(GO) mod tidy

build: mod clean test build-mac build-windows build-linux-amd64
	echo "build done"
#	$(GOBUILD) -o $(CMD_BINARY_NAME) -v ./cmd/cmd.go
#	shasum -a 256 $(CMD_BINARY_NAME)

# Cross compilation
build-linux-amd64:
	export CGO_ENABLED=0 GOOS=linux GOARCH=amd64
	$(GOBUILD) -o $(CMD_BINARY_NAME)_linux -v ./cmd/cmd.go
	#shasum -a 256 $(CMD_BINARY_NAME)_linux
build-windows:
	xgo --targets="windows/*" -dest=$(BINARY_PATH) ./cmd/
	#export CGO_ENABLED=0 GOOS=windows GOARCH=386
	#$(GOBUILD) -o $(CMD_BINARY_NAME)_windows.exe -v ./cmd/cmd.go
	#shasum -a 256 $(CMD_BINARY_NAME)_windows
build-mac:
	export CGO_ENABLED=0 GOOS=darwin GOARCH=amd64
	$(GOBUILD) -o $(CMD_BINARY_NAME)_mac -v ./cmd/cmd.go
	#shasum -a 256 $(CMD_BINARY_NAME)_mac
docker-build:
	docker run --rm -it -v "$(GOPATH)":/go -w /go/src/data_model_go golang:latest go build -o "$(CMD_BINARY_NAME)" -v

publish: clean-dir publish-linux publish-windows publish-mac

clean-dir:
	rm -rf ./release/*
	rm -f release_*.zip

publish-common-init:
	mkdir -p ./release/storage/logs && chmod -R 777 ./release/storage
	cp -r ./assets ./release
	cp .env.example ./release
	cp .env.example ./release/.env
	cp ./deploy/business_event.sql ./release

publish-mac: publish-common-init
	cp ./bin/business_data_model_mac ./release
	zip -r release_mac-`date +%Y%m%d`.zip release
	rm -rf ./release/*

publish-windows: publish-common-init
	cp ./bin/business_data_model_windows.exe ./release
	zip -r release_windows-`date +%Y%m%d`.zip release
	rm -rf ./release/*

publish-linux: publish-common-init
	cp ./bin/business_data_model_linux ./release
	zip -r release_linux-`date +%Y%m%d`.zip release
	rm -rf ./release/*