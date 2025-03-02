#!/bin/bash

MQTT_BROKER="192.168.2.58"

TOPIC="${1:-iotstack/antenna/data}"
PAYLOAD="$2"

mosquitto_pub -h "$MQTT_BROKER" -t "$TOPIC" -m "$PAYLOAD"
