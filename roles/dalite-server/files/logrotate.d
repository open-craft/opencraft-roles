/var/log/dalite/student.log {
        daily
        missingok
        ifempty
        dateext
        create 0666 dalite dalite
        rotate 3653
        postrotate
            /usr/local/sbin/dalite-dalite-post-logrotate.sh
        endscript
}
