# ros-kinetic-nvidia-docker
Extends the `osrf/ros:kinetic-desktop-full`, 'craymichael /
ros-kinetic-nvidia-docker' [here](https://github.com/craymichael/ros-kinetic-nvidia-docker) images containing opengl, glvnd and cuda 8.0. This makes opengl work from any docker environment when used with
[nvidia-docker2](https://github.com/NVIDIA/nvidia-docker). Thanks to
[phromo](https://github.com/phromo/ros-indigo-desktop-full-nvidia) for the
baseline. 

To extend the Dockerfile (e.g. to add more ROS packages or users), take a
look at the commented out lines at the end of file.

# Installation
1. Install docker
2. Install nvidia-docker:

 ```distribution=$(. /etc/os-release;echo $ID$VERSION_ID)```

 ```curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -```
 
 ```curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list``` 

more information [here](https://github.com/NVIDIA/nvidia-docker).

3. After cloning this repo, ```run
`sudo ./build_the_docker.sh```` to ```build it and
4. ``` sudo ./run_the_docker.sh``````
to start the container```
