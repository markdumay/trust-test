# trust-test
Temp repo to test automated Docker signing


## Signing images
Back in 2015, Docker introduced the feature to digitally sign images stored in a registry through a concept called Docker Content Trust (DCT). These signatures allow client-side or runtime verification of the integrity and publisher of specific image tags. The Center for Internet Security recommends to enforce DCT in a production environment. Setting the environment variable `DOCKER_CONTENT_TRUST=1` instructs Docker to only use images that are digitally signed.


https://docs.docker.com/engine/security/trust/
https://www.cisecurity.org/benchmark/docker/