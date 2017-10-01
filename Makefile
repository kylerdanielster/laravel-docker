.PHONY: up down log tinker artisan test new composer

# Set dir of Makefile to a variable to use later
MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))

up:
	docker-compose up -d

down:
	docker-compose down

log:
	tail -f $(PWD)storage/logs/laravel.log | awk '\
		{matched=0}\
		/INFO:/    {matched=1; print "\033[0;37m" $$0 "\033[0m"}\
		/WARNING:/ {matched=1; print "\033[0;34m" $$0 "\033[0m"}\
		/ERROR:/   {matched=1; print "\033[0;31m" $$0 "\033[0m"}\
		/Next/     {matched=1; print "\033[0;31m" $$0 "\033[0m"}\
		/ALERT:/   {matched=1; print "\033[0;35m" $$0 "\033[0m"}\
		/Stack trace:/ {matched=1; print "\033[0;35m" $$0 "\033[0m"}\
		matched==0            {print "\033[0;33m" $$0 "\033[0m"}\
	'

tinker:
	docker run -it --rm \
		-e "HOME=/home" \
		-v $(PWD).tinker:/home/.config \
		-v $(PWD):/opt \
		-w /opt \
		--network=phpapp_appnet \
		jesmaybe/php:latest \
		php artisan tinker

ART=""
artisan:
	docker run -it --rm \
		-e "HOME=/home" \
		-v $(PWD).tinker:/home/.config \
		-v $(PWD):/opt \
		-w /opt \
		--network=phpapp_appnet \
		jesmaybe/php:latest \
		php artisan $(ART)

test:
	docker run -it --rm \
		-v $(PWD):/opt \
		-w /opt \
		--network=phpapp_appnet \
		jesmaybe/php:latest \
		./vendor/bin/phpunit

new:
	docker run -it --rm \
		-v $(pwd):/opt \
		-w /opt \
		--network=phpapp_appnet \
		jesmaybe/php \
		composer create-project laravel/laravel .

CMP=""
composer:
	docker run -it --rm \
		-v $(pwd):/opt \
		-w /opt \
		--network=phpapp_appnet \
		jesmaybe/php \
		composer $(CMP)
	
