# import env variables from .env file
include .env
export $(grep -v '^#' .env | xargs)

# git commit and push, with message
commit_push:
	@git commit -m "$(MESSAGE)"
	@git push
