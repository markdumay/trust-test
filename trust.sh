#!/bin/sh

readonly TRUST_DIR="${HOME}/.docker/trust"
readonly DOCKER_REGISTRY='docker.io'
readonly NOTARY_SERVER='https://notary.docker.io'
readonly DOCKER_REPOSITORY_NAME='markdumay/trust'
# readonly GITHUB_REPOSITORY_NAME='markdumay/trust-test'
# readonly DELEGATION_USER='testuser'
# readonly WORKING_DIR='./'
readonly NOTARY_CONFIG="${HOME}/.notary/config.json"
readonly NOTARY_JSON_CONFIG="{
    \"trust_dir\" : \"${TRUST_DIR}\",
    \"remote_server\": {
        \"url\": \"${NOTARY_SERVER}\"
    }
}"

# initialize the local notary client configuration, if not present already
init_notary_config() {
    if [ ! -f "${NOTARY_CONFIG}" ]; then
        mkdir -p dirname "${NOTARY_CONFIG}"
        printf '%s' "${NOTARY_JSON_CONFIG}" > "${NOTARY_CONFIG}"
    fi
}

# initialize Docker trust for a Docker repository
init_docker_repository_trust() {
    owner="$1"
    owner_path="$2"
    repository="$3"

    docker login
    docker trust key generate "${owner_path}"
    docker trust signer add --key "${owner_path}".pub "${owner}" "${repository}"
}

# generate a private key for a delegation user
generate_delegation_key() {
    key_path="$1"

    openssl genrsa -out "${key_path}".key 2048
    openssl req -new -sha256 -key "${key_path}".key -out "${key_path}".csr
    openssl x509 -req -sha256 -days 365 -in "${key_path}".csr -signkey "${key_path}".key -out "${key_path}".crt
}

# import a private delegation key into the local trust store
import_delegation_key() {
    user="$1"
    passphrase="$2"
    [ -n "${user}" ] || return 1
    [ -z "${passphrase}" ] && passphrase=$(openssl rand -base64 32)
    
    # import the private key using the specified passphrase
    export NOTARY_DELEGATION_PASSPHRASE="${passphrase}"
    notary key import "${user}".key --role "${user}" || return 1

    # return the passphrase when successful
    echo "${passphrase}"
    return 0
}

# authorize a delegation user to sign images of a remote Docker repository
authorize_delegation_user() {
    docker login
    repository_url="${DOCKER_REGISTRY}/${DOCKER_REPOSITORY_NAME}"
    notary delegation add "${repository_url}" targets/releases "${key_path}".crt --all-paths
    notary publish "${repository_url}"
}


# revoke_delegation_user() {

# }

# signs a locally-built Docker image in the remote repository
sign_image_tag() {
    image_tag="$1:$2"

    export DOCKER_CONTENT_TRUST=1
    docker tag "${image_tag}" "${image_tag}"
    docker push "${image_tag}" || return 1

    return 1
}

# delegate_path="${WORKING_DIR}/${DELEGATION_USER}"
# owner_path="${WORKING_DIR}/${OWNER}"

# $1 - user name
# $2 - repository
init_notary_config
passphrase=$(import_delegation_key "$1") || "Cannot import delegation key"
# sign_image_tag 'markdumay/trust:0.2.4'
sign_image_tag "$2"