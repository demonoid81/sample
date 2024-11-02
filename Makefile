.PHONY: prepare #build test

$(eval $(service):;@:)
check:
	@[ "${service}" ] || ( echo "\x1b[31;1mERROR: 'service' is not set\x1b[0m"; exit 1 )
	@if [ ! -d "cmd/$(service)" ]; then  echo "\x1b[31;1mERROR: service '$(service)' undefined\x1b[0m"; exit 1; fi

build: check
	@go build -o build/$(service) cmd/$(service)/*.go

proto: check
	@if [ ! -d "sdk/$(service)" ]; then echo "creating new proto files..." &&  mkdir sdk/$(service) && mkdir sdk/$(service)/proto; fi
	$(foreach proto_file, $(shell find internal/services/$(service)/api/proto -name '*.proto'),\
	protoc --proto_path=internal/services/$(service)/api/proto \
		-I./sdk/proto \
		--go_out=sdk/$(service)/proto \
		--go_opt=paths=source_relative \
		--go-grpc_out=sdk/$(service)/proto \
		--go-grpc_opt=paths=source_relative $(proto_file) \
		--grpc-gateway_out sdk/$(service)/proto \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--openapiv2_out ./cmd/docs/swagger \
                --openapiv2_opt logtostderr=true \
                --openapiv2_opt use_go_templates=true )

# mocks all interfaces in sdk for unit test
mocks:
	@mockery --all --keeptree --dir=sdk --output=./sdk/mocks
	@if [ -f sdk/mocks/Option.go ]; then rm sdk/mocks/Option.go; fi;

#docker tag SOURCE_IMAGE[:TAG] 5.188.140.93:8043/ecomm/IMAGE[:TAG]
#docker push 5.188.140.93:8043/ecomm/IMAGE[:TAG]
docker: check
	docker build --build-arg SERVICE_NAME=$(service) -t 5.188.140.93:8043/ecomm/wa-$(service):latest  --platform=linux/amd64 .

run-container: check
	docker run --name=$(service) --network="host" -d $(service)

# unit test & calculate code coverage from selected services (please run mocks before run this rule)
test: check
	@echo "\x1b[32;1m>>> running unit test and calculate coverage for service $(service)\x1b[0m"
	@if [ -f cmd/$(service)/coverage.txt ]; then rm cmd/$(service)/coverage.txt; fi;
	@go test -race ./internal/services/$(service)/... -cover -coverprofile=cmd/$(service)/coverage.txt -covermode=atomic \
		-coverpkg=$$(go list ./cmd/$(service)/... | grep -v -e mocks -e codebase | tr '\n' ',')
	@go tool cover -func=cmd/$(service)/coverage.txt

# creates a directory for linter reports
reportdir:
	@mkdir -p .reports

# process linter in specified service directory files
lint: check reportdir
	@-golangci-lint cache clean
	@-golangci-lint run --allow-parallel-runners --enable-all --disable gci --go 1.18 --out-format checkstyle \
 	internal/services/$(service)/*.go \
 	> .reports/lint-report.xml
