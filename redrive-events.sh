#!/bin/bash

# NOTE: Schema:
# CREATE TABLE predict_passes(
#     sat_name text not null,
#     pass_start timestamp primary key default (strftime('%s', 'now')) not null,
#     pass_end timestamp default (strftime('%s', 'now')) not null,
#     max_elev int not null,
#     is_active boolean, pass_start_azimuth int, direction text, azimuth_at_max int, at_job_id int not null default 0);

DB_FILE="/home/pi/raspberry-noaa-v2/db/panel.db"
SCRIPTS_DIR="${NOAA_HOME}/scripts"


scheduled_passes=$(sqlite3 $DB_FILE "SELECT * FROM predict_passes;")
while IFS='|' read -r sat_name pass_start pass_end max_elev is_active pass_start_azimuth direction azimuth_at_max at_job_id; do
    PAYLOAD=$(jq -n \
        --arg sat_name "$sat_name" \
        --arg pass_start "$pass_start" \
        --arg pass_end "$pass_end" \
        --arg max_elev "$max_elev" \
        --arg is_active "$is_active" \
        --arg pass_start_azimuth "$pass_start_azimuth" \
        --arg azimuth_at_max "$azimuth_at_max" \
        --arg direction "$direction" \
        --arg at_job_id "$at_job_id" \
        '{enable_mqtt: true, satellite: {name: $sat_name, pass_start: $pass_start, pass_end: $pass_end, max_elev: $max_elev, is_active: $is_active, pass_start_azimuth: $pass_start_azimuth, azimuth_at_max: $azimuth_at_max, direction: $direction, at_job_id: $at_job_id}}')
    "$SCRIPTS_DIR/mqtt.sh" "iotstack/antenna/schedule" "$PAYLOAD"
done <<< "$(echo "$scheduled_passes")"iotstack/antenna/schedule" "$PAYLOAD"
