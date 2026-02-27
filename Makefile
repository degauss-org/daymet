.PHONY: build test shell clean

build:
	docker build -t daymet .

test:
	docker run -e USER="my_username" -e PASSWORD="my_password" --rm -v "${PWD}":/tmp daymet daymet_degauss_test.csv

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}":/tmp daymet

clean:
	docker system prune -f
