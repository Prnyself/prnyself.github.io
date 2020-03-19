.PHONY: help
help:
	@echo "Please use \`make <target>\` where <target> is one of"
	@echo "  server     		to start local server environment"


.PHONY: server
server:
	@echo "Start local server..."
	@jekyll s