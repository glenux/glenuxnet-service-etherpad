
USERNAME:=glenux
IMAGE:=$(shell basename "$$(pwd)")
TAG:=$(shell TZ=UTC date +"%Y%m%d")

all: 

build:
	docker build -t $(USERNAME)/$(IMAGE):$(TAG) .

run:
	# remplir ici

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

