NODE=node
MOCHA=node_modules/mocha/bin/mocha
KARMA=node_modules/karma/bin/karma
BOURBON=node_modules/bourbon/app/assets/stylesheets
SASS=node_modules/node-sass/bin/node-sass
VIGILIA=node_modules/vigilia/bin/vigilia
WEBPACK=node_modules/webpack/bin/webpack.js
PM2=node_modules/pm2/bin/pm2
GIT=git

.PHONY: deploy-worker run stop logs monit test worker runner scheduler clean-client scripts-client styles-client watch-client

# scheduler & runner tasks

worker: scheduler runner leaderboard

scheduler:
	$(NODE) workers/scheduler.js

leaderboard:
	$(NODE) workers/leaderboard.js

runner:
	$(NODE) workers/runner.js --use_strict

# app tasks

test:
	$(MOCHA)

run: build-client
	cp -n .env-sample .env || true
	export `cat .env| grep -v -e "^#"` && $(PM2)-dev start config/dev.json

stop:
	$(PM2) delete config/dev.json

# client tasks

build-client: clean-client scripts-client styles-client images-client

watch-client: build-client
	$(VIGILIA) 'client/scripts/**/*.js':'make scripts-client-dev' 'client/styles/**/*.scss':'make styles-client'

clean-client:
	rm -fr public
	rm -f npm-debug.log

images-client:
	cp client/images/thumbnail.png public/thumbnail.png

tree-client:
	mkdir -p public/scripts
	mkdir -p public/styles

scripts-client: tree-client
	$(WEBPACK) --bail -p client/scripts/main.js public/scripts/main.js
	$(WEBPACK) --bail -p client/scripts/playground.js public/scripts/playground.js

scripts-client-dev: tree-client
	$(WEBPACK) --bail client/scripts/main.js public/scripts/main.js
	$(WEBPACK) --bail client/scripts/playground.js public/scripts/playground.js

styles-client: tree-client
	$(SASS) --include-path $(BOURBON) --output public/styles --output-style compressed --quiet client/styles/main.scss public/styles/main.css
	$(SASS) --include-path $(BOURBON) --output public/styles --output-style compressed --quiet client/styles/playground.scss public/styles/playground.css
