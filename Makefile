
USERNAME:=glenux
IMAGE:=$(shell basename "$$(pwd)")
TAG:=$(shell TZ=UTC date +"%Y%m%d")

all: 

build:
	docker-compose build 

run:
	docker-compose up --detach

logs:
	docker-compose logs -f

shell:
	docker-compose exec etherpad bash

kill:
	docker-compose kill

test: build
	# remplir ici

# on produit des binaires, on les stocke qqpart
#
deliver:
	# remplir ici

# on utilise les binaires pour faire fonctionner le service
# en ligne
#
# deploy:
# 	# ...

