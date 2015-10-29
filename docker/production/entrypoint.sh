#!/bin/bash
set -e

cd /var/www/app
# run startup script, like migrations

echo 'hi'

# run the CMD
exec "$@"
