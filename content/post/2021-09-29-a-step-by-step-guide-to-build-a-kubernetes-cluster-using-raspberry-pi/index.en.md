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

1. Go to [Operating system images](https://www.raspberrypi.org/software/operating-systems/) and download the latest versions of Raspberry Pi OS with desktop and Raspberry Pi OS Lite, and download any image flash software or follow this example and simply use the Raspberry Pi Imager available [here](https://www.raspberrypi.org/software/).

2. Launch the Raspberry Pi Imager and click 'CHOOSE OS' --> go to 'Use costom' and find and select the Raspberry Pi OS image we previously downloaded, then click 'CHOOSE STORAGE' and select the MicroSD card storage location on your PC. Repeat this process for every MicroSD card. Note that to follow this example I will be flashing the Raspbian OS with desktop onto the master node and Raspbian OS Lite onto all other (worker) nodes. (Tip: one of the benefit of using Raspberry Pi Imager is that you can do Ctrl-Shift-X during the flashing process and gain access to set some system options such as enable ssh, configure wifi etc.)

<img src="images/2021-09-29 10_40_25-Clipboard.png" alt="" width="400px"/>

3. 