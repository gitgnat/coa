.PHONY: all ghc init

# install gems and packages to make a dev environment
dev: init
	bundle exec rake cabal:clobber
	bundle exec rake dev:init

# build from source to get the recent version of ghc: 7.8.3
ghc: init
	bundle exec rake ghc:install

init:
	sudo apt-get update -y
	sudo apt-get install -y ghc cabal-install happy alex
	sudo gem install rake bundler
	bundle install

