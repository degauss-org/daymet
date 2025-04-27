.PHONY: build test shell clean

build:
	docker build -t daymet .

test:
	docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:0.1.4 my_addresses.csv --vars=tmax

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}":/tmp daymet

clean:
	docker system prune -f
