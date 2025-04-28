.PHONY: build test shell clean

build:
	docker build -t daymet .

test:
	docker run --rm -v "${PWD}":/tmp daymet loyalty_degauss.csv

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}":/tmp daymet

clean:
	docker system prune -f
