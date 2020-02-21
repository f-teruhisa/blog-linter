default:lint

init:
	docker-compose build

lint:
	docker-compose run --rm linter ./node_modules/.bin/textlint post/post.md

fix: 
	docker-compose run linter ./node_modules/.bin/textlint --fix post/post.md
