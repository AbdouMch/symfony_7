#!/bin/bash

set -eo pipefail

echo "Running linter"

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$PROJECT_DIR"

IFS='
'
RC=0
RED='\033[0;31m'
GREEN='\033[0;32m'
REDBG='\033[41m'
NC='\033[0m' # No Color


CHANGED_FILES="$(git diff --name-only --diff-filter=ACMR ${1:-'HEAD'})"
CHANGED_PHP_FILES="$(grep -e '\.php$' <<< "${CHANGED_FILES}" ||:)"
CHANGED_PHP_FILES_ARR=(${CHANGED_PHP_FILES})
CHANGED_JS_FILES="$(grep -e '\.js' <<< "${CHANGED_FILES}" ||:)"
CHANGED_JS_FILES_ARR=(${CHANGED_JS_FILES})
CHANGED_TWIG_FILES="$(grep -e '\.twig' <<< "${CHANGED_FILES}" ||:)"
CHANGED_TWIG_FILES_ARR=(${CHANGED_TWIG_FILES})

PHP_CONTAINER='frankenphp_symfo_7'

# PHP Files
if [[ -n "$CHANGED_PHP_FILES" ]]; then
    echo "* PHP: ${#CHANGED_PHP_FILES_ARR[@]} changed files"

    echo ""
    echo "- PHP Errors"
    FAILED_FILES=""
    for (( i=0; i<${#CHANGED_PHP_FILES_ARR[@]}; i++ )); do
        if ! php -l -d display_errors=0 "${CHANGED_PHP_FILES_ARR[$i]}" >/dev/null; then
            FAILED_FILES="$FAILED_FILES ${CHANGED_PHP_FILES_ARR[$i]}"
        fi
    done
    if [[ -n "$FAILED_FILES" ]]; then
        RC=1
    fi

    echo ""
    echo "- PHP CS-Fixer"
    if [[ $RC == 1 ]]; then
        echo -e " ${RED} SKIPPED ${NC}"
    else
        if docker exec -w /app/public ${PHP_CONTAINER} ./vendor/bin/php-cs-fixer fix --verbose --config=.php-cs-fixer.dist.php --using-cache=no -- "${CHANGED_PHP_FILES_ARR[@]}"; then
            echo ""
        else
            RC=1
        fi
    fi

    echo ""
    echo "- PhpStan"
    if docker exec -w /app/public ${PHP_CONTAINER} php -d memory_limit=-1 ./vendor/bin/phpstan analyse -- "${CHANGED_PHP_FILES_ARR[@]}"; then
        echo ""
    else
        RC=1
    fi

    echo ""
    echo "- Container Lint"
    if docker exec -w /app/public ${PHP_CONTAINER} php bin/console lint:container; then
        echo ""
    else
        RC=1
    fi

    # TODO Symfony 5.1 : php bin/console debug:container --deprecations
fi

# JS Files
if [[ -n "$CHANGED_JS_FILES" ]]; then
    echo ""
    echo "* JS: ${#CHANGED_JS_FILES_ARR[@]} changed files"
    echo ""
    echo "- XO"
    if ./node_modules/.bin/eslint --fix -- "${CHANGED_JS_FILES_ARR[@]}"; then
        echo ""
    else
        RC=1
    fi
fi

# TWIG Files
if [[ -n "$CHANGED_TWIG_FILES" ]]; then
    echo "* TWIG: ${#CHANGED_TWIG_FILES_ARR[@]} changed files"

    echo ""
    echo "- TWIG Lint"
    if docker exec -w /app/public ${PHP_CONTAINER} php bin/console lint:twig "${CHANGED_TWIG_FILES_ARR[@]}" --show-deprecations; then
        echo ""
    else
        RC=1
    fi
fi

if [[ $RC == 0 ]]; then
    echo -e " ${GREEN} ✔ OK ${NC}"
else
    echo -e " ${REDBG} ERROR ${NC}"
fi
echo ""
exit $RC
