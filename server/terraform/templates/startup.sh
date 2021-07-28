#!/usr/bin/env bash
set -euo pipefail

# Avoid Terraform template by either using double dollar signs, or not using curly braces
readonly SCRIPT_NAME="$(basename "$0")"
readonly MARKER_PATH="/etc/startup-marker"
readonly TEAMCITY_DATA_MOUNT="${data_mount_path}"
readonly TEAMCITY_DIRECTORY="/opt/teamcity"

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "$${timestamp} [$${level}] [$$SCRIPT_NAME] $${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$${message}"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$${message}"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$${message}"
}

function generate_cert () {
    local readonly admin_email="$${1}"
    local readonly domain_name="$${2}"
    log_info "Generating LetsEncrypt certificate"
    certbot certonly --quiet --agree-tos --keep-until-expiring \
        --rsa-key-size 4096 \
        -m "$${admin_email}" \
        --dns-google -d "$${domain_name}" \
        --dns-google-propagation-seconds 90
}

function mount_data() {
    local readonly device_name="$${1}"
    local readonly mount_path="$${2}"

    until ls "$${device_name}"; do
        log_info 'Waiting for data device to be mounted'
        sleep 5
    done

    log_info "Mounting data volume"
    mkdir -p "$${mount_path}"
    mount -o discard,defaults "$${device_name}" "$${mount_path}"

    local readonly uuid="$(blkid -s UUID -o value "$${device_name}")"

    if [ -z "$(grep $${uuid} /etc/fstab)" ]
    then
        echo "UUID=$${uuid} $${mount_path} ext4 discard,defaults,nofail 0 2" >> /etc/fstab
    fi

    # Safety Check
    mount -a

    log_info "Creating nginx directory"
    mkdir -p $${mount_path}/nginx

    log_info "Make sure data volume ownership is 1000:1000"
    chown -R 1000:1000 $${mount_path}/{teamcity,nginx,logs}

    log_info "Creating LetsEncrypt certificate directory"
    mkdir -p /etc/letsencrypt/{live,renewal,archive}
    mkdir -p $${mount_path}/letsencrypt/{live,renewal,archive}
    for dir in live renewal archive
    do
        if [ -z "$(grep $${mount_path}/letsencrypt/$dir /etc/fstab)" ]
        then
            echo "$${mount_path}/letsencrypt/$dir /etc/letsencrypt/$dir none rw,bind 0 0" >> /etc/fstab
        fi
        mount -o bind $${mount_path}/letsencrypt/$dir /etc/letsencrypt/$dir
    done

    # Safety Check
    mount -a
}

function configure_teamcity() {
    local readonly teamcity_directory="$${1}"
    local readonly teamcity_data_mount="$${2}"

    mkdir -p "$${teamcity_directory}/nginx"

    local compose_config=$(cat <<EOF
${compose_config}
EOF
)
    local nginx_config=$(cat <<EOF
${nginx_config}
EOF
)
    log_info "Writing TeamCity nginx config file"
    echo -n "$${nginx_config}" > "$${teamcity_directory}/nginx/teamcity.conf"
    log_info "Writing TeamCity Compose file"
    echo -n "$${compose_config}" > "$${teamcity_directory}/docker-compose.yml"
}

function start_teamcity() {
    local readonly teamcity_directory="$${1}"
    cd "$${teamcity_directory}"
    docker-compose up -d
}

function main() {
    if [ ! -f "$${MARKER_PATH}" ]; then
        mount_data "/dev/disk/by-id/google-${data_device_name}" "$${TEAMCITY_DATA_MOUNT}"

        generate_cert "${admin_email}" "${teamcity_base_url}"

        configure_teamcity "$${TEAMCITY_DIRECTORY}" "$${TEAMCITY_DATA_MOUNT}"

        start_teamcity "$${TEAMCITY_DIRECTORY}"

        # Touch the marker file to indicate completion
        touch "$${MARKER_PATH}"
    fi
}

main "$@"
