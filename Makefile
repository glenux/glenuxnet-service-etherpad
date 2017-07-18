
all: build run

# --build-arg "BUNDLE_BITBUCKET__ORG=$(BUNDLE_BITBUCKET__ORG)" \

build:
	docker build -t dt-service-pad .

run:
	docker run --rm -p 9001:9001 \
		-e DATABASE_URL="mysql://user:foo@databasehost/database?options" \
		-t dt-service-pad \
		#


