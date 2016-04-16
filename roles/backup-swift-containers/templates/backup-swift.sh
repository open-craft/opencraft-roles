#!/usr/bin/env bash

# Exits after first failure
set -e

timestamp=$(date +%Y%m%dT%H:%M:%S)

{{ LOCAL_SWIFT_SHELL_COMMAND }} download -D "{{ BACKUP_SWIFT_LOCAL_DIR }}"  "{{BACKUP_SWIFT_CONTAINER}}"
/usr/local/bin/tarsnap -c --keyfile "{{ tarsnap_key }}" --cachedir "{{ tarsnap_cache }}" -f "{{ BACKUP_SWIFT_BACKUP_NAME }}-${timestamp}" "{{ BACKUP_SWIFT_LOCAL_DIR }}"
{% if BACKUP_SWIFT_SNITCH %}
curl "{{ BACKUP_SWIFT_SNITCH }}"
{% endif %}