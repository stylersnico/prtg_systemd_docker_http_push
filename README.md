# Systemd units and Docker containers monitoring for PRTG

Monitor one or more systemd units and/or Docker services for PRTG using the HTTP Push Data Advanced sensor.

Set an OK status for units that are active or an Error status for units that are not active.
Also give usage details for Docker containers.

The units monitored can be services or any other type of units.


## Requirements

- Linux
- systemd
- bash


## How to use

Both script outputs XML suitable for PRTG's advanced sensor types. It can be used with HTTP Push Data Advanced sensor using the `prtg_push_advanced.sh` script.

For the systemd part, the units you want to monitor can be specified staticly inside the script `systemd_units.sh`, for example:
```bash
units=(sshd httpd firewalld)
```

Unit types other than services must have their type suffix specified. You may also be able to specify mount units by their mount point path instead of their unit name.


For the docker part, the containers you want to monitor can be specified staticly inside the script `systemd_units.sh`, for example:
```bash
CONTAINERS="paperless_db_1 paperless_broker_1 paperless_webserver_1 watchtower paperless_tika_1 paperless_gotenberg_1"
```



## Setup as HTTP Push Sensor

TBW ...

## Special thanks

- Evanlinde for it's prtg_systemd monitor and prtg_push script: https://github.com/evanlinde/prtg_systemd + https://github.com/evanlinde/prtg_push
- In-famous-raccoon for the idea of docker monitoring in json, completly rewritten in XML for pushing the result to PRTG and not using JSON and a webserver for delivery: https://github.com/in-famous-raccoon/Docker-Stats-4-PRTG


Schedule your push command to run on a regular basis (e.g. with cron or a systemd timer).

