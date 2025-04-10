# import env variables from .env file
include .env
export $(shell sed 's/=.*//' .env)

# git commit and push, with message
commit_push:
	@git commit -m "$(MESSAGE)"
	@git push
