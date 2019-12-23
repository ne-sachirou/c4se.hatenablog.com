.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-16s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: format
format: ## Format.
ifdef FORMAT_TARGET
	npx prettier --write '${FORMAT_TARGET}'
	npx textlint --fix '${FORMAT_TARGET}'
else
	ag -l '\r' | xargs -t -I{} sed -i -e 's/\r//' {}
	npx prettier --write *.md */*.md
	npx prettier --write package.json
	npx textlint --fix *.md */*.md
endif

.PHONY: init
init: ## Initialize.
	npm install
	npm fund

.PHONY: test
test: ## Test.
	yamllint .yamllint .github/workflows/*.yml
	npm audit
	npm outdated
	npx textlint */*.md || true

.PHONY: watch
watch: ## Watch file changes & do things.
ifeq  ($(shell uname),Darwin)
	fswatch -e '/\.' --event=Created --event=Updated --event=MovedTo -f "%Y%m%d%H%M" --format "%t	%p" 2019 2020 | \
	unbuffer -p uniq | \
	awk -F"	" '{print$$2}{system("")}' | \
	xargs -t -I{} $(MAKE) FORMAT_TARGET='{}' format
else
	inotifywait -m -e create,modify,moved_to --exclude '(/\..+)|/$$' --timefmt "%Y%m%d%H%M" --format "%T	%w%f" 2019 2020 | \
	stdbuf -oL -eL uniq | \
	awk -F"	" '{print$$2}{system("")}' | \
	xargs -t -I{} $(MAKE) FORMAT_TARGET='{}' format
endif
