# ros-kinetic-nvidia-docker
Extends the `osrf/ros:kinetic-desktop-full`, 'craymichael /
ros-kinetic-nvidia-docker' [here](https://github.com/craymichael/ros-kinetic-nvidia-docker) images containing opengl, glvnd and cuda 8.0. This makes opengl work from any docker environment when used with [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker). Thanks to [phromo](https://github.com/phromo/ros-indigo-desktop-full-nvidia) for the baseline. 

# Requirements
- Ubuntu 16.04/18.04/20.04


# Installation
1. Install docker:
      [here the guide](https://docs.docker.com/engine/install/ubuntu/)
      
2. Install nvidia-docker:

      ```distribution=$(. /etc/os-release;echo $ID$VERSION_ID)```

      ```curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -```

      ```curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list``` 

      ```apt update```

      ```apt install nvidia-docker2```

     more information [here](https://github.com/NVIDIA/nvidia-docker).

3. After cloning this repo, run
```sudo ./build_the_docker.sh```  to build it and

4. ``` sudo ./run_the_docker.sh``` to start the container
