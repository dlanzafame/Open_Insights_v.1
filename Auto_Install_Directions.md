**Docker Based Graylog Health Module Installation Guide**

**Version 1.0**

#

#

# Contents

[***1.*** **Scope** ](#_Toc81948407)

[***2.*** **Objective** ](#_Toc81948408)

[***3.*** **Assumptions** ](#_Toc81948409)

[***4.*** **Installing Exporters** ](#_Toc81948410)

[***5.*** **Docker Software Prerequisites** ](#_Toc81948411)

[***6.*** **Graylog Health Module Docker Image** ](#_Toc81948412)

[***7.*** **Downloading Graylog Health Module Automation Script** ](#_Toc81948413)

[***8.*** **Installing the package** ](#_Toc81948414)

#


# **Scope**

This document provides instructions on how to consume the Docker based Graylog Health Module setup for a greenfield implementation which will be monitoring Graylog health metrics.


# **Objective**

An automation script has been provided that will take care of following tasks

- Download Docker image from the Docker repo
- Instantiate the docker container that is running the Gryalog Health Module and Graylog Support Dashboard.
- Connect to Graylog target servers and Elastic search nodes
- Configuration the Graylog Health Module to start collecting relevant metrics


# **Assumptions**

This implementation uses different types of exporters for collecting metrics data.

- Node Exporter, Graylog exporter, Elasticsearch exporter, and MongoDB exporter must be installed manually on target servers. Separate scripts are provided for installing those exporters
- Firewall settings, opening of relevant ports etc must be done to enable communications between the Gryalog Health Module and target servers
- Following port numbers are assumed: Node Exporter on 9100, Graylog exporter on 9000, Elasticsearch exporter on 9114, MongoDB exporter on 9216 and Pushgateway on 9091
- These ports must be reachable between target Graylog and ElasticSearch servers as well as the Graylog Health Module and the Graylog Support Dashboard.
- Firewall settings, opening of relevant ports must be done. Port 9090 for the Graylog Health Module, 9093 for Alert manager, 3000 for the Graylog Support Dashboard and 9100 for Node-exporter.


# **installing exporters (to be done on target nodes only)**

Note that following exporters must be installed for correct operations on Target nodes.

- Node Exporter, Graylog Exporter, and MongoDB exporter on Graylog Application nodes
- Node Exporter, Pushgateway, Elasticsearch Exporter on Elastic Search nodes

Downloading exporter package

The exporter package can be download from:

https://datacloud.altnix.com/exporter.tar.gz

Use following commands:

_#curl https://datacloud.altnix.com/exporter.tar.gz -o_ _exporter__.tar.gz_   ####CHANGE THIS LINE TO REFLECT NEW LOCATION

_#tar xvf exporter.tar.gz -C /opt/_

_#cd /opt/exporter/_

Folder Structure

You will find following folders:

- node\_exporter
- elasticsearch\_exporter
- mongodb\_exporter

Installing Exporters

- Graylog exporter should be already installed by default in its plugins directory on Target and no action is needed.
###ADD IN DIRECTIONS ON INSTALLING GRAYLOG EXPORTER
- Run the script inside /opt/exporter/node\_exporter/install.sh for both Node Exporter and Pushgateway installation.
- Run the script inside /opt/exporter/elasticsearch\_exporter/install.sh for Elasticsearch exporter.
- Run the script inside /opt/exporter/mongodb\_exporter/install.sh for MongoDB exporter. Note that MongoDB metric access will need credentials. Hence mongodb\_exporter install script will ask for id and password to configure it.
- Every exporter folder contains an uninstall script to uninstall that Exporter.


# **docker software Prerequisites**

- Docker software must be running on the server where you want to eventually install the Graylog Health Module Docker image. For more instructions on installing Docker software, please refer to:

[https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

- The install script has to be run with &quot;sudo su&quot;.

1.
# **Graylog Health Module docker image**

Graylog Health Module Docker and related images are currently uploaded to:

[https://hub.docker.com/repository/docker/altnix/prometheus01](https://hub.docker.com/repository/docker/altnix/prometheus01)

You don&#39;t need to login here since the Automation script takes care of the download.

1.
# **downloading prometheus automation script**

Automation script for this project is available for download from

https://datacloud.altnix.com/graydocker.tar.gz ###CHANGE ADDRESS

1.
# **steps for installing the package (to be done on the Graylog Health Module server**

These steps must be performed on the Graylog Health Module server where you want Graylog Health Module / Graylog Support Dashboard setup done.

- Note: The install script has to be run with &quot;sudo su&quot;.

**Step 1** – Copy Graylog Health Module package

_#curl https://datacloud.altnix.com/graydocker.tar.gz -o graydocker.tar.gz_   ####CHANGE ADDRESS

_#tar xvf graydocker.tar.gz -C /opt/_

**Step 2** – Running the script

_#cd /opt/graydocker/
 #./install.sh_

This script will run with following steps:

- Step 1: Check Docker, Hardware resource and collect Server details.

This will check whether the Docker software is installed and is it running.

Check for minimum 4GB RAM and Processor 4 core available.

- Step 2: Collect Information on Graylog setup.

It will detect and ask to confirm local server IP address.

It will also ask whether Graylog and MongoDB are separate server from Elasticsearch server.

Collect IP address for Graylog server.

Collect metric access id and password for Graylog server.

Confirm Elasticsearch is running on default port 9200.

Ask for Elasticsearch id and password if configured.

- Step 3: Configure Graylog Health Module and Graylog Support Dashboard.

Configure Graylog Health Module with given IP, login id and password details.

Configure Graylog Support Dashboard datasource

- Step 4: Install Docker containers. of Graylog Support Dashboard, Graylog Health Module, Alertmanager and Node-exporter.

Pull and run Graylog Support Dashboard, Graylog Health Module, Alertmanager and Node-exporter docker containers from docker hub.

- Step 5: Test the setup.

Check all the containers are running.

Check all the exporters on scraping metrics to Graylog Health Module.

Giving access info to Graylog Health Module and Graylog Support Dashboard.

Everything has been automated in the script so you just need to respond to the prompts

**Step 3:** Troubleshooting

- The install log is available in /_opt_/graydocker/var/install.log for reference.
- Any manual correction on IP or id/password can be done at /_opt_/graydocker/etc/prometheus/prometheus.yml
- In case there is need to re-install the setup again on the same server, please use the re-uninstall.sh script.
  - The script is available at: /_opt_/graydocker/re-uninstall.sh
  - Uninstall will completely remove Graylog Health Module related files and components

**Step 4:** Accessing Graylog Health Module Web Interface

Use the following URL to access UI.

http://\&lt;server-IPaddress\&gt;:9090

**S ![](RackMultipart20210913-4-vjeeqz_html_391208f2f8fb7246.png)
 tep 5:** Accessing Graylog Support Dashboard Web Interface

Use the following Url to access UI.

http://\&lt;server-IPaddress\&gt;:3000

![](RackMultipart20210913-4-vjeeqz_html_b9e9431eb6175e72.png)

**Step 6:** Accessing Alertmanager Web Interface

Use the following URL to access UI.

**http://\&lt;server-IPAddress\&gt;:9093**

![](RackMultipart20210913-4-vjeeqz_html_a33b7281484043aa.png)

![](RackMultipart20210913-4-vjeeqz_html_cad24c7539197f26.png)
