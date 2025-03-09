#!/bin/bash

DB_FILE="/home/pi/raspberry-noaa-v2/db/panel.db"


scheduled_passes=$(sqlite3 $DB_FILE "SELECT OBJ_NAME, start_epoch_time, end_epoch_time, max_elev, starting_azimuth, azimuth_at_max, direction, at_job_id FROM predict_passes;")

while IFS='|' read -r OBJ_NAME start_epoch_time end_epoch_time max_elev starting_azimuth azimuth_at_max direction at_job_id; do
    PAYLOAD=$(jq -n \
        --arg sat_name "$OBJ_NAME" \
        --arg pass_start "$start_epoch_time" \
        --arg pass_end "$end_epoch_time" \
        --arg max_elev "$max_elev" \
        --arg is_active "1" \
        --arg pass_start_azimuth "$starting_azimuth" \
        --arg azimuth_at_max "$azimuth_at_max" \
        --arg direction "$direction" \
        --arg at_job_id "$at_job_id" \
        '{enable_mqtt: true, satellite: {name: $sat_name, pass_start: $pass_start, pass_end: $pass_end, max_elev: $max_elev, is_active: $is_active, pass_start_azimuth: $pass_start_azimuth, azimuth_at_max: $azimuth_at_max, direction: $direction, at_job_id: $at_job_id}}')
    "$SCRIPTS_DIR/mqtt.sh" "iotstack/antenna/schedule" "$PAYLOAD"
done <<< "$scheduled_passes"