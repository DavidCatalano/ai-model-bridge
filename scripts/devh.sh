#!/bin/bash

case "$1" in
    "build-repo")
        docker-compose build --build-arg CACHEBUST=$(date +%s)
        ;;
    "build-no-cache")
        docker-compose build --no-cache
        ;;
    "bash")
        docker-compose run --rm modelbridge --interactive $2
        ;;
    "attach")
        docker exec -it modelbridge bash        
        ;;
    *)
        echo "Usage: $0 {build-repo|setup-pip|setup-bash|bash}"
        exit 1
        ;;
esac
