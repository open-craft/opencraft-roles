#!/usr/bin/env bash

source /etc/profile

# Zero means true :)
is_ok=0
report="{{ SANITY_CHECK_LOG_LOCATION }}"
echo > ${report};

{% for mount in SANITY_CECK_DISK_SPACE %}
disk_space_left_mb=$(df -m "{{ mount.mount }}" | grep "{{ mount.mount }}" | awk '{ print $4}');
disk_space_threshold="{{mount.treshold_mb}}"
if test ${disk_space_threshold} -gt ${disk_space_left_mb}
then
    is_ok=1;
    echo "Only ${disk_space_left_mb}mb left on {{ mount.mount }}. Threshold is: ${disk_space_threshold}" >> ${report};
fi
{% endfor %}

{% for port in SANITY_CHECK_LIVE_PORTS %}
if ! nc -z "{{ port.host }}" "{{ port.port}}"
then
    is_ok=1;
    echo "{{ port.description}}" >> ${report};
fi
{% endfor %}

{% for command in SANITY_CHECK_COMMANDS %}
if ! {{command.command}}
then
    is_ok=1;
    echo "{{ command.description}}" >> ${report};
fi
{% endfor %}

{% if SANITY_CHECK_SNITCH %}
if test ${is_ok} -eq 0
then
    curl "{{ SANITY_CHECK_SNITCH }}"
fi
{% endif %}

if test ${is_ok} -ne 0
then
    echo "Something is wrong mailing root"
    echo >> "Please check report in {{ SANITY_CHECK_LOG_LOCATION }}";
    cat ${report} | mail -s "{{ SANITY_CHECK_SUBJECT }}" root;
fi
