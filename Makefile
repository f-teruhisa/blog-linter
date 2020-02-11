default: up

init:
	docker-compose build

up:
	docker-compose up

lint:
	docker-compose run linter ./node_modules/.bin/textlint post/post.md

fix: 
	docker-compose run linter ./node_modules/.bin/textlint --fix post/post.md
