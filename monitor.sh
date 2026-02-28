#!/bin/bash

# Configuration
GRAFANA_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="admin"
DASHBOARD_FILE="dashboard.json"

# Function to wait until Grafana is up
wait_for_grafana() {
    echo "Waiting for Grafana to start..."
    until curl -s -o /dev/null -w "%{http_code}" "$GRAFANA_URL/api/health" | grep -q "200"; do
        sleep 2
    done
    echo "Grafana is up!"
}

# Start Grafana (systemd service)
echo "Starting Grafana..."
sudo systemctl start grafana-server

# Wait until Grafana is fully started
wait_for_grafana

# Import dashboard
if [ -f "$DASHBOARD_FILE" ]; then
    echo "Importing dashboard from $DASHBOARD_FILE..."
    curl -s -X POST -H "Content-Type: application/json" \
        -u "$ADMIN_USER:$ADMIN_PASS" \
        -d @"$DASHBOARD_FILE" \
        "$GRAFANA_URL/api/dashboards/db" \
        | jq .
    echo "Dashboard import complete."
else
    echo "Error: $DASHBOARD_FILE not found!"
fi
