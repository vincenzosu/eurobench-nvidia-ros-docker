FROM osrf/ros:kinetic-desktop-full

RUN rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

# ==================
# below sourced from https://gitlab.com/nvidia/opengl/blob/ubuntu16.04/base/Dockerfile

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        libxau6 libxau6:i386 \
        libxdmcp6 libxdmcp6:i386 \
        libxcb1 libxcb1:i386 \
        libxext6 libxext6:i386 \
        libx11-6 libx11-6:i386 && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# ==================
# below sourced from https://gitlab.com/nvidia/opengl/blob/ubuntu14.04/1.0-glvnd/runtime/Dockerfile

RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils && \
    apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        make \
        automake \
        autoconf \
        libtool \
        pkg-config \
        python \
        libxext-dev \
        libx11-dev \
        x11proto-gl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/libglvnd

RUN git clone --branch=v1.0.0 https://github.com/NVIDIA/libglvnd.git . && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/x86_64-linux-gnu && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/x86_64-linux-gnu -type f -name 'lib*.la' -delete

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        gcc-multilib \
        libxext-dev:i386 \
        libx11-dev:i386 && \
    rm -rf /var/lib/apt/lists/*

# ================== 32-bit libraries
RUN make distclean && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/i386-linux-gnu --host=i386-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/i386-linux-gnu -type f -name 'lib*.la' -delete

COPY 10_nvidia.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    echo '/usr/local/lib/i386-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig

ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# ==================
# below sourced from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile

RUN apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION_MAJOR=8.0 \
    CUDA_VERSION_MINOR=61 \
    CUDA_PKG_EXT=8-0
ENV CUDA_VERSION=$CUDA_VERSION_MAJOR.$CUDA_VERSION_MINOR
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvrtc-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-nvgraph-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-cusolver-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-cublas-dev-$CUDA_PKG_EXT=$CUDA_VERSION.2-1 \
        cuda-cufft-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-curand-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-cusparse-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-npp-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-cudart-dev-$CUDA_PKG_EXT=$CUDA_VERSION-1 \
        cuda-misc-headers-$CUDA_PKG_EXT=$CUDA_VERSION-1 && \
    ln -s cuda-$CUDA_VERSION_MAJOR /usr/local/cuda && \
    ln -s /usr/local/cuda-8.0/targets/x86_64-linux/include /usr/local/cuda/include && \
    rm -rf /var/lib/apt/lists/*

# ================== nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# ================== nvidia-container-runtime
ENV NVIDIA_REQUIRE_CUDA="cuda>=$CUDA_VERSION_MAJOR"

# ================== ROS Stuff
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    apt-get update

# ================== Install ROS packages
#RUN apt-get update && apt-get install -y \
#        ros-kinetic-ecc
#    rm -rf /var/lib/apt/lists/*

# ================== Add new sudo user
#ENV USERNAME=username
#RUN useradd -m $USERNAME && \
#        echo "$USERNAME:$USERNAME" | chpasswd && \
#        usermod --shell /bin/bash $USERNAME && \
#        usermod -aG sudo $USERNAME && \
#        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
#        chmod 0440 /etc/sudoers.d/$USERNAME && \
#        usermod  --uid 1000 $USERNAME && \
#        groupmod --gid 1000 $USERNAME

# Change default user and working directory
# USER roseurobench
WORKDIR /home/roseurobench/

# ================== REEM-C installation
RUN sudo apt update
RUN sudo apt install wget
RUN sudo apt-get install ros-kinetic-catkin python-catkin-tools
RUN echo $(pwd)
RUN mkdir reemc_public_ws && \
	 cd reemc_public_ws
WORKDIR  /home/roseurobench/reemc_public_ws
RUN echo $(pwd)

RUN wget https://raw.githubusercontent.com/pal-robotics/reemc_tutorials/kinetic-devel/reemc_tutorials.rosinstall
RUN rosinstall src /opt/ros/kinetic reemc_tutorials.rosinstall
RUN sudo rm /etc/ros/rosdep/sources.list.d/20-default.list; exit 0
RUN rosdep init && \
	sudo rosdep fix-permissions && \
	rosdep update
RUN rosdep install --from-paths src --ignore-src --rosdistro kinetic \
	--skip-keys="opencv2 pal_laser_filters speed_limit_node \
	sensor_to_cloud hokuyo_node libdw-dev gmock walking_utils \
	rqt_current_limit_controller simple_grasping_action \
	reemc_init_offset_controller walking_controller"; exit 0

RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash"
#RUN /bin/bash -c "echo $(pwd)"
WORKDIR /home/roseurobench/reemc_public_ws/src
#RUN /bin/bash -c "catkin_init_workspace"

#RUN catkin build -DCATKIN_ENABLE_TESTING=0
#RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash"

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
#RUN /bin/bash -c "source ~/.bashrc"

# ================== sapienza  Open the door
RUN git clone https://github.com/JoseJaramillo/reemc_door

# ================== madrob performance indicator
RUN git clone https://github.com/madrob-beast/madrob_beast_pi.git
#RUN python -m pip install -e madrob_beast_pi/src/madrob_beast_pi

# ================== madrob
RUN git clone https://github.com/madrob-beast/eurobench_benchmarking_software.git
RUN git clone https://github.com/madrob-beast/madrob_msgs.git
RUN git clone https://github.com/madrob-beast/madrob_srvs.git
RUN git clone https://github.com/madrob-beast/beast_msgs.git
RUN git clone https://github.com/madrob-beast/beast_srvs.git
#RUN rosdep install --from-paths ./src --ignore-src

# ================== madrob-reemc brdge (TODO ADD when repo will be public)
#RUN git clone https://github.com/vincenzosu/eurobench_state_collector

# other ros dependecies
RUN sudo apt install -y ros-kinetic-realtime-tools  \ 
	ros-kinetic-control-toolbox \
	ros-kinetic-four-wheel-steering-msgs \
	ros-kinetic-moveit-ros-planning-interface \
	ros-kinetic-humanoid-nav-msgs \
	ros-kinetic-urdf-geometry-parser \
	python3-pandas 
RUN pip install PyYAML==5.1 

#RUN echo "$(pwd)"

RUN echo "\n\n \033[92m  \
DON'T FORGET TO RUN  catkin build -DCATKIN_ENABLE_TESTING=0 inside the docker \n \
NB: the run script takes on input the id of this container tht you can find \
at end of this procedure \n\n \033[0m "

SHELL ["/bin/bash", "-c", "source ../devel/setup.bash"]
#SHELL [ "/bin/bash", "-c", "catkin build -DCATKIN_ENABLE_TESTING=0"]

