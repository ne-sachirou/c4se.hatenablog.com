.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-16s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: format
format: ## Format.
	ag -l '\r' | xargs -t -I{} sed -i -e 's/\r//' {}
	prettier --write */*.md
