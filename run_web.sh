#!/bin/bash
ip=$(ipconfig getifaddr en0)
echo "$ip:8080"
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080