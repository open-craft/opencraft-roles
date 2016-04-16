# Will exit on first error (we want it!)
set -e

service gunicorn restart

timestamp=$(date +%Y%m%dT%H:%M:%S)

mv /var/log/dalite/student.log-* "{{ DALITE_LOG_DOWNLOAD_LOG_DIR }}"
chown "{{ DALITE_LOG_DOWNLOAD_USER }}:{{ MYSQL_DALITE_USER }}" "{{ DALITE_LOG_DOWNLOAD_LOG_DIR }}" "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}"
chmod g+rwx "{{ DALITE_LOG_DOWNLOAD_LOG_DIR }}" "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}"
sudo -u "{{ MYSQL_DALITE_USER }}" -H {{DALITE_MANAGE_PY}} dumpdata -o "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}/database.json-${timestamp}"
mysqldump -u "{{ MYSQL_DALITE_USER }}" -p'{{ MYSQL_DALITE_PASSWORD }}' -h "{{ MYSQL_DALITE_HOST }}" "{{ MYSQL_DALITE_DATABASE }}" -r "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}/database.sql-${timestamp}"
chown "{{ DALITE_LOG_DOWNLOAD_USER }}:{{ DALITE_LOG_DOWNLOAD_USER }}" "{{ DALITE_LOG_DOWNLOAD_LOG_DIR }}"/* "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}"/*
tarsnap -c --keyfile "{{tarsnap_key}}" --cachedir "{{tarsnap_cache}}" -f "{{ DALITE_LOG_TARSNAP_ARCHIVE }}-${timestamp}" "{{ DALITE_LOG_DOWNLOAD_LOG_DIR }}" "{{ DALITE_LOG_DOWNLOAD_DB_DIR }}"
{% if DALITE_LOG_TARSNAP_SNITCH %}
curl {{ DALITE_LOG_TARSNAP_SNITCH }}
{% endif %}