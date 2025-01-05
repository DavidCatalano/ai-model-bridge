#!/bin/bash

case "$1" in
    "build-repo")
        # docker-compose build --build-arg CACHEBUST=$(date +%s)
        docker-compose build --build-arg CACHEBUST=$(date +%s) | tee build.log
        ;;
    "build-no-cache")
        docker-compose build --no-cache | tee build.log
        ;;
    "cli")
        docker-compose run --rm modelbridge --interactive $2
        ;;
    "attach")
        docker exec -it modelbridge bash        
        ;;
    *)
        echo "Usage: $0 {build-repo|build-no-cache|cli|attach}"
        exit 1
        ;;
esac
