~~~
java -jar projects/springbox-kafka-player/target/springbox-kafka-player-0.8.0.jar \
    --sql-port 14415 \
    --sql-database default_db \
    --sql-command "SELECT user_id, payload, created_in_utc FROM event WHERE topic = 'incoming' and created_in_utc BETWEEN '2025-03-01 00:08:00' AND '2025-03-01 23:59:59' ORDER BY id" \
    --sql-user application \
    --sql-password password \
    --kafka-host localhost \
    --kafka-port 13053 \
    --kafka-topic incoming
~~~

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
