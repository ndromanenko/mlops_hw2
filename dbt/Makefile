-include .env
export

DBT := uv run dbt

.PHONY: all deps seed run test docs docs-serve

all: deps seed run test

deps:
	$(DBT) deps

seed:
	$(DBT) seed

run:
	$(DBT) run

test:
	$(DBT) test

docs:
	$(DBT) docs generate

docs-serve: docs
	$(DBT) docs serve --port 8090
