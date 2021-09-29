---
title: A step-by-step guide to build a Kubernetes cluster using Raspberry Pi
author: zhoufang
date: '2021-09-29'
slug: []
categories:
  - Raspberry Pi
  - Kubernetes
tags:
  - Raspberry Pi
  - Linux
  - DIY
  - Kubernetes
  - Docker
description: ~
featured_image: ~
---

<img src="images/unnamed (3).jpg" alt="" width="500px"/>

Follow this step-by-step guide if you have a few Raspberry Pis available and want to build a on-premises Kubernetes cluster and then deploy some containerized applications such as WordPress and MySQL on the cluster.

A few things are needed:

- At least 2 Raspberry Pis of model 3b, 3b+ or (preferably) 4.
- MircroSD card of at least 8GB for each Pi
- A Wi-Fi connection or a Ethernet cable for each Pi

I have a few Raspberry Pis at hand and for this project I will be using my Raspberry Pi 4 Model B with 4GB RAM as the master node, and a RPi 3 Model B+ plus a RPi 3 Model B as its 2 worker nodes, it is recommended to use your most capable Pi as your master node since it will require more resources.

<img src="images/unnamed (2).jpg" alt="" width="350px"/>

To get started first we need to flash operating systems into the memory card of each Pi - since we will be running our Pis 'headlessly' (each Pi will be remotely accessed without a need to attach monitor & other accessories), it is recommended that we install Raspbian OS Lite instead of a full-fledged Raspbian OS with GUI, since we want to preserve as much resources as possible to make available to the cluster. 

I am however going to instal a Raspbian OS w/ GUI onto the RPi4 (master) with the benefit of being able to access application deployment on the localhost such as Kubernetes-Dashboard without a need to use VMs or mess with config files on a remote PC which I will get into later.

It is also possible to opt for Ubuntu instead of the Raspbian OS which I will not get into here as the Raspbian OS will be sufficient for all intends and purposes of this post.

### Install Raspbian OS (Lite)

- Go to [Operating system images](https://www.raspberrypi.org/software/operating-systems/) and download the latest versions of Raspberry Pi OS with desktop and Raspberry Pi OS Lite, and download any image flash software or follow this example and simply use the Raspberry Pi Imager available [here](https://www.raspberrypi.org/software/).

- Launch the Raspberry Pi Imager and click 'CHOOSE OS' --> go to 'Use costom' and find and select the Raspberry Pi OS image we previously downloaded, then click 'CHOOSE STORAGE' and select the MicroSD card storage location on your PC. Repeat this process for every MicroSD card. Note that to follow this example I will be flashing the Raspbian OS with desktop onto the master node and Raspbian OS Lite onto all other (worker) nodes. (Tip: one of the benefit of using Raspberry Pi Imager is that you can do Ctrl-Shift-X during the flashing process and gain access to set some system options such as enable ssh, configure wifi etc.)
- Click 'WRITE' and wait for it to finish.

<img src="images/2021-09-29 10_40_25-Clipboard.png" alt="" width="400px"/>

### Configure OS to prepare for Kubernetes installation

-  Assume that you did not opt for using the Ctrl-Shift-X feature previously mentioned, we now need to activate SSH connection (so that we can securely remote into our RPis) and to configure Wi-Fi (if not being connected via an ethernet cable).

-  If you are able to hook your Raspberry Pi to a Monitor and a Keyboard, you can proceed with inserting the newly flashed MicroSD card into the Pi and type `sudo raspi-config` into the configuration tool that came with Raspbian OS and easily enable SSH and configure Wi-Fi, otherwise one needs to follow below steps for a 'headless' way of setup. 

**SSH**

To enable SSH connection we need to add a file named ssh in the boot partition. 

*(Linux/MacOS)*

Open your terminal and cd into /Volumes/boot:

`cd Volumes/boot`

Then create the ssh file:
`touch ssh`

*(Windows)*

Look for your boot drive location on the newly flash MicroSD card and let's say it is G:, use Win+X and select Windows PowerShell (Admin) to launch PowerShell with Admin right, type `G:` to navigate to the boot partition, then type

`new-item ssh`

If using an ethernet connection to connect your Pi to the internet then it is good to go, otherwise we still need to configure Wi-Fi before the SD card is made ready to insert into the Pi.

**Wi-Fi**

To configure Wi-Fi, we need to create a *file wpa_supplicant.conf* file under the boot partition:

*(Linux/MacOS)*

Open your terminal and cd into /Volumes/boot:

`cd Volumes/boot`

Create the ssh file:
`sudo nano file wpa_supplicant.conf`

Then paste into the .conf file below content, substituting the part of `<WIFI NAME>` and `<WIFI password>` for your own.

`update_config=1
 ctrl_interface=/var/run/wpa_supplicant
 network={
 scan_ssid=1
 ssid="<WIFI NAME>"
 psk="<WIFI password>"
 }`

Ctrl-X to save and Y to confirm, now wifi is set up.

*(Windows)*

Create the same *file wpa_supplicant.conf* under the boot drive.

**Configurations**

Now that we have SSH and internet connection setup we can go ahead and insert the MicroSD card into the Pi, wait for it to be ready for SSH connection which usually will take less than 1 minute unless something went wrong.

To check if our Raspberry Pi boots correctly, go to command prompt(Windows) or terminal(MacOS) and SSH connect to our Pi by typing `ssh pi@192.168.x.x` and enter password defaulted as `raspberry` (Find your Raspberry Pi IP address by log on to the router admin typically at https://192.168 1.1 for your Raspberry Pi's IP address, or use 'ifconfig' or 'hostname -I' if you have your Pi connected to a monitor)

Once SSH connection successfully to the Raspbery Pi, type

`sudo vi /boot/cmdline.txt`

and add 'cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' at the end of the line.

We are also going to need to flush our iptables by `sudo iptables -F` as part of the requirement to enable us to use `K3S`.

Finally, reboot the system using `sudo reboot` and we will be ready to install Kubernetes.

### Install Kubernetes

On our master node, install `K3S` as such

`curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s`

Once installed we need to get our node-token from the master in order proceed with K3S installation on our worker nodes.

`cat /var/lib/rancher/k3s/server/node-token`

With the token copied, install K3S on worker nodes using

`curl -sfL https://get.k3s.io | K3S_TOKEN="<master_node_token>" K3S_URL="https://<master_node_ip_address>:6443" K3S_NODE_NAME="<worker_name>" sh -`

For example if your master node token is 'RPIFUN' with an IP address of '192.168.1.123' and you intend to name it 'rpi-worker1' then the command to install K3S on our 1st worker node will be:

`curl -sfL https://get.k3s.io | K3S_TOKEN="RPIFUN" K3S_URL="https://192.168.1.123:6443" K3S_NODE_NAME="rpi-worker1" sh -`

> kubectl: the CLI administration tool for Kubernetes

Once K3S is installed on our master node as well as all of the worker nodes, we can check the status of our kubernetes cluster by typing `kubectl get nodes`, better, we can add `-w` at the end so that we can watch the status of our nodes and eventually we should have all of our nodes appearing and READY.

<img src="images/2021-09-29 15_39_47-Command Prompt.png" alt="" width="500px"/>

### Deploy Kubernetes-Dashboard

`kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml`

Running the Kubectl command creates both the Kubernetes dashboard service and deployment. It also creates a default service account, role, role binding and secret for the dashboard: 

Once we create the dashboard we can access it using Kubectl. To do this we will spin up a proxy server between our local machine and the Kubernetes apiserver.

`Kubectl proxy`

Kubectl proxy is the recommended way of accessing the Kubernetes REST API. It uses http for the connection between localhost and the proxy server and https for the connection between the proxy and apiserver.

We can access the Kubernetes dashboard UI by browsing to the following url, from our master node Raspbian OS Desktop browser: 

`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`

<img src="images/2021-09-29 16_06_31-Clipboard.png" alt="" width="600px"/>