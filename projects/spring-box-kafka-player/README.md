# Empty

~~~
java -jar projects/spring-box-kafka-player/target/spring-box-kafka-player-0.7.1.jar \
    --sql-port 14415 \
    --sql-database default_db \
    --sql-command "SELECT user_id, payload, created_in_utc FROM event WHERE topic = 'incoming' and created_in_utc BETWEEN '2025-03-01 00:08:00' AND '2025-03-01 23:59:59' ORDER BY id" \
    --sql-user application \
    --sql-password password \
    --kafka-host localhost \
    --kafka-port 13053 \
    --kafka-topic incoming
~~~
