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
    echo "" >> /etc/fstab
    echo "UUID=$${uuid} $${mount_path} ext4 discard,defaults,nofail 0 2" >> /etc/fstab
    # Safety Check
    mount -a
}

function configure_teamcity() {
    local readonly teamcity_directory="$${1}"
    local readonly teamcity_data_mount="$${2}"

    mkdir -p "$${teamcity_directory}"

    local compose_config=$(cat <<EOF
${compose_config}
EOF
)
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
        configure_teamcity "$${TEAMCITY_DIRECTORY}" "$${TEAMCITY_DATA_MOUNT}"

        start_teamcity "$${TEAMCITY_DIRECTORY}"

        # Touch the marker file to indicate completion
        touch "$${MARKER_PATH}"
    fi
}

main "$@"
