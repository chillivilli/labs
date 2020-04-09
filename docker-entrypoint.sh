#!/bin/bash
set -e

if [[ "${1#-}" != "$1" ]]; then
    if [[ "${APP_TYPE}" = 'supervisor' ]]; then
        set -- /usr/bin/supervisord "$@"
    else
        set -- apache2-foreground "$@"
    fi
fi

if [[ "$1" = '/usr/bin/supervisord' ]] || [[ "$1" = 'apache2-foreground' ]]; then
    echo "build project...${APP_TYPE}:${APP_ENV}"

	mkdir -p ${PROJECT_CACHE_DIR} ${PROJECT_LOG_DIR}
	setfacl -dR -m u:dev:rwX -m u:"$(whoami)":rwX ${PROJECT_CACHE_DIR}
	setfacl -dR -m u:dev:rwX -m u:"$(whoami)":rwX ${PROJECT_LOG_DIR}
    composer install --prefer-dist --no-progress --no-suggest --no-interaction

    if [[ -e vendor/bin/phing ]]; then
        vendor/bin/phing -Dapp.env="${APP_ENV}" -Dapp.type="${APP_TYPE}"
    fi

    if [[ -e bin/phing && -e build.xml ]]; then
        bin/phing -Dapp.env="${APP_ENV}" -Dapp.type="${APP_TYPE}"
    fi
fi

exec "$@"
