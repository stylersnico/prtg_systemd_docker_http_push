# Systemd units and Docker containers monitoring for PRTG

Monitor one or more systemd units and/or Docker services for PRTG using the HTTP Push Data Advanced sensor.

Set an OK status for units that are active or an Error status for units that are not active.
The units monitored can be services or any other type of units.

Give full usage details for Docker containers on host.

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


For the docker part, the containers you want to monitor can be specified staticly inside the script `DockerStats4PRTGxml.sh`, for example:
```bash
CONTAINERS="paperless_db_1 paperless_broker_1 paperless_webserver_1 watchtower paperless_tika_1 paperless_gotenberg_1"
```

## Setup 
Download all scripts : 
```bash
mkdir -p /var/prtg/scriptsxml
cd /var/prtg/scriptsxml
wget https://raw.githubusercontent.com/stylersnico/prtg_systemd_docker_http_push/refs/heads/main/DockerStats4PRTGxml.sh
wget https://raw.githubusercontent.com/stylersnico/prtg_systemd_docker_http_push/refs/heads/main/prtg_push_advanced.sh
wget https://raw.githubusercontent.com/stylersnico/prtg_systemd_docker_http_push/refs/heads/main/systemd_units.sh
chmod +x *
```

## Setup as HTTP Push Sensor

- Configure `DockerStats4PRTGxml.sh` and `systemd_units.sh` to monitor what you need.
- Create a new HTTP Push Data Advanced sensor in PRTG, then enter the settings and grab the "**Identification token**" in PRTG.
- Then launch the following command to test it (adapt to the script you want to use):
```bash
/var/prtg/scriptsxml/DockerStats4PRTGxml.sh | /var/prtg/scriptsxml/prtg_push_advanced.sh -a "http://PRTGSERVER:5050" -t "token"
```

The feedback of the command should look like this:
```bash
{"status":"Ok","Matching Sensors":"1"}
```

## Crontab

Open your crontab:
```bash
crontab -e
```

Configure the launch every minute like this:
```bash
* * * * * /var/prtg/scriptsxml/systemd_units.sh | /var/prtg/scriptsxml/prtg_push_advanced.sh -a "http://PRTGSERVER:5050" -t "xxx" > /dev/null 2>&1
* * * * * /var/prtg/scriptsxml/DockerStats4PRTGxml.sh | /var/prtg/scriptsxml/prtg_push_advanced.sh -a "http://PRTGSERVER:5050" -t "xxx" > /dev/null 2>&1
```

## Screenshots
<img width="1581" height="802" alt="docker-example" src="https://github.com/user-attachments/assets/0901166c-a8b0-4aad-b723-b1aa55e79253" />
<img width="1564" height="800" alt="systemd-example" src="https://github.com/user-attachments/assets/ceae64af-1a93-4492-b17b-13e0571ab755" />


## Special thanks

- Evanlinde for it's prtg_systemd monitor and prtg_push script: https://github.com/evanlinde/prtg_systemd + https://github.com/evanlinde/prtg_push
- In-famous-raccoon for the idea of docker monitoring in json, completly rewritten in XML for pushing the result to PRTG and not using JSON and a webserver for delivery: https://github.com/in-famous-raccoon/Docker-Stats-4-PRTG
