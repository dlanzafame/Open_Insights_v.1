**Docker Based Graylog Health Module Installation Guide**

**Version 1.0**

#

#

# Contents

[***1.*** **Scope** ]

[***2.*** **Objective** ]

[***3.*** **Assumptions** ]

[***4.*** **Installing Exporters** ]

[***5.*** **Docker Software Prerequisites** ]

[***6.*** **Graylog Health Module Docker Image** ]

[***7.*** **Downloading Graylog Health Module Automation Script** ]

[***8.*** **Installing The Package** ]

#


# **Scope**

This document provides instructions on how to utilize the Docker-based Graylog Health Module setup for monitoring Graylog health metrics.


# **Objective**

An automation script has been provided that will take care of following tasks:

- Download Docker image from the Docker repo.
- Instantiate the docker container that is running the Graylog Health Module and Graylog Support Dashboard.
- Connect to Graylog target servers and ElasticSearch nodes.
- Configure the Graylog Health Module to start collecting relevant metrics.


# **Assumptions**

This implementation uses different types of exporters for collecting metrics data.

- Node Exporter, Graylog exporter, ElasticSearch exporter, and MongoDB exporter must be installed manually on target servers. Separate scripts are provided for installing those exporters.
- Firewall settings, opening of relevant ports, etc must be done to enable communications between the Graylog Health Module and target servers.
- The following port numbers are assumed: Node Exporter on 9100, Graylog exporter on 9000, Elasticsearch exporter on 9114, MongoDB exporter on 9216 and Pushgateway on 9091.
- These ports must be reachable between the target Graylog and ElasticSearch servers as well as the Graylog Health Module and the Graylog Support Dashboard.
- Firewall settings and opening of relevant ports that must be done: Port 9090 for the Graylog Health Module, 9093 for Alert manager, 3000 for the Graylog Support Dashboard and 9100 for Node-exporter.


# **installing exporters (To be done on target nodes only)**

Note that following exporters must be installed for correct operations on Target nodes.

- Node Exporter, Graylog Exporter, and MongoDB exporter on Graylog Application nodes
- Node Exporter and Elasticsearch Exporter on Elastic Search nodes

Downloading exporter package

The exporter package can be download from:
####CHANGE THIS LINE TO REFLECT NEW LOCATION
[//]: # (https://datacloud.altnix.com/exporter.tar.gz)

Use following commands:
####CHANGE THIS LINE TO REFLECT NEW LOCATION
[//]: # (_#curl https://datacloud.altnix.com/exporter.tar.gz -o_ _exporter__.tar.gz_ )

```bash
tar xvf exporter.tar.gz -C /opt/

cd /opt/exporter/
```
Folder Structure

You will find following folders:
```bash
node\_exporter
elasticsearch\_exporter
mongodb\_exporter
```
Installing Exporters

- Graylog Metrics Exporter should be already installed by default in its plugins directory (/usr/share/graylog-server/plugin) on the target server. If it is not, use the following commands to install it.
```bash
cd /usr/share/graylog-server/plugin
wget https://github.com/graylog-labs/graylog-plugin-metrics-reporter/releases/download/3.0.0/metrics-reporter-prometheus-3.0.0.jar
systemctl restart graylog-server
```
- Run the script inside /opt/exporter/node_exporter/install.sh for both Node Exporter and Pushgateway installation.
- Run the script inside /opt/exporter/elasticsearch_exporter/install.sh for Elasticsearch exporter.
- Run the script inside /opt/exporter/mongodb_exporter/install.sh for MongoDB exporter. Note that MongoDB metric access will need credentials. Hence mongodb_exporter install script will ask for id and password to configure it.
- Every exporter folder contains an uninstall script to uninstall that specific Exporter.


# **Docker software Prerequisites**

- Docker software must be running on the server where you want to eventually install the Graylog Health Module Docker image. For more instructions on installing Docker software, please refer to:

[https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

- The install script has to be run with &quot;sudo su&quot;.

# **Graylog Health Module Docker image**

Graylog Health Module Docker and related images are located at:
####CHANGE THIS LINE TO REFLECT NEW LOCATION
[//]: # ([https://hub.docker.com/repository/docker/altnix/prometheus01](https://hub.docker.com/repository/docker/altnix/prometheus01))

You do not need to login here since the Automation script takes care of the download.

# **Downloading Graylog Health Module automation script**

Automation script for this project is available for download from:
###CHANGE ADDRESS
[//]: # (https://datacloud.altnix.com/graydocker.tar.gz) 


# **Installing the package (to be done on the Graylog Health Module server)**

These steps must be performed on the Graylog Health Module server where you want Graylog Health Module / Graylog Support Dashboard setup done.

- Note: The install script has to be run with &quot;sudo su&quot;.

**Step 1** – Copy Graylog Health Module package
####CHANGE ADDRESS
[//]: # (_#curl https://datacloud.altnix.com/graydocker.tar.gz -o graydocker.tar.gz_ )  
```bash
tar xvf graydocker.tar.gz -C /opt/
```
**Step 2** – Running the script
```bash
cd /opt/graydocker/
./install.sh_
```
This script will run with following steps:

- Step 1: Check Docker, Hardware resources, and collect Server details.

This will check whether the Docker software is installed and if it is running.

Check for minimum 4GB RAM and Processor 4 core available.

- Step 2: Collect Information on Graylog setup.

It will detect and ask to confirm local server IP address.

It will also ask whether Graylog and MongoDB are separate servers from the Elasticsearch server.

Collect IP address for Graylog server.

Collect metric access id and password for Graylog server.

Confirm Elasticsearch is running on default port 9200.

Ask for Elasticsearch id and password if configured.

- Step 3: Configure Graylog Health Module and Graylog Support Dashboard.

Configure Graylog Health Module with given IP, login id, and password details.

Configure Graylog Support Dashboard datasource

- Step 4: Install Docker containers of Graylog Support Dashboard, Graylog Health Module, Alertmanager, and Node-exporter.

Pull and run Graylog Support Dashboard, Graylog Health Module, Alertmanager and Node-exporter docker containers from docker hub.

- Step 5: Test the setup.

Check all the containers are running.

Check all the exporters on scraping metrics to Graylog Health Module.

Give access info to Graylog Health Module and Graylog Support Dashboard.

**Step 3:** Troubleshooting

- The install log is available in /opt/graydocker/var/install.log for reference.
- Any manual correction on IPs or id/password can be done at /opt/graydocker/etc/prometheus/prometheus.yml
- In case there is need to re-install the setup again on the same server, please use the re-uninstall.sh script.
  - The script is available at: /opt/graydocker/re-uninstall.sh
  - Uninstall will completely remove Graylog Health Module related files and components

**Step 4:** Accessing Graylog Health Module Web Interface

Use the following URL to access UI.

http://server-IPaddress:9090

**Step 5:** Accessing Graylog Support Dashboard Web Interface

Use the following Url to access UI.

http://server-IPaddress:3000

**Step 6:** Accessing Alertmanager Web Interface

Use the following URL to access UI.

**http://server-IPAddress:9093**
