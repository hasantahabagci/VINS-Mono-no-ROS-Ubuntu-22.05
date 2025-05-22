######### 1st stage – build OpenCV + Ceres + Pangolin ###############################
ARG L4T_TAG=r36.4.0 # <- override on build if you need another tag
FROM nvcr.io/nvidia/l4t-jetpack:${L4T_TAG} AS builder
ENV DEBIAN_FRONTEND=noninteractive

# --- Build prerequisites -----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential cmake git wget ninja-build pkg-config \
    python3-dev python3-numpy python3-pip \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libgtk-3-dev libcanberra-gtk* libv4l-dev \
    libboost-all-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev \
    libeigen3-dev libgoogle-glog-dev libgflags-dev \
    libatlas-base-dev libsuitesparse-dev \
    libepoxy-dev libglew-dev \
    libxi-dev libxxf86vm-dev libxrandr-dev libxinerama-dev libxcursor-dev \
    libgl1-mesa-dev libudev-dev && \
    rm -rf /var/lib/apt/lists/*

# --- Build Ceres Solver ------------------------------------------------------------
WORKDIR /opt
RUN wget -q http://ceres-solver.org/ceres-solver-2.2.0.tar.gz && \
    tar zxf ceres-solver-2.2.0.tar.gz && \
    mkdir ceres-bin && \
    cd ceres-bin && \
    cmake ../ceres-solver-2.2.0 -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# --- Build Pangolin ----------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \
    mkdir build && cd build && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_FLAGS="-w" \
      -DCMAKE_CXX_FLAGS="-w" && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# --- Build OpenCV ------------------------------------------------------------------
WORKDIR /opt
RUN git clone --branch 4.10.0 --depth 1 https://github.com/opencv/opencv.git && \
    git clone --branch 4.10.0 --depth 1 https://github.com/opencv/opencv_contrib.git
WORKDIR /opt/opencv/build
RUN cmake -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
    -D WITH_GTK=ON \
    -D WITH_QT=OFF \
    -D WITH_OPENGL=ON \
    -D WITH_CUDA=ON \
    -D CUDA_ARCH_BIN=8.7 \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D WITH_GSTREAMER=ON \
    -D WITH_CERES=ON \
    -D BUILD_opencv_sfm=OFF \
    -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=/usr/bin/python3.10 \
    -D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3.10 \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D OPENCV_ENABLE_NONFREE=ON .. && \
    ninja install && ldconfig


# Full GStreamer + runtime tools ----------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip libopenblas-base libgfortran5 \
    gstreamer1.0-tools gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-gl gstreamer1.0-x gstreamer1.0-gtk3 \
    gstreamer1.0-alsa && \
    rm -rf /var/lib/apt/lists/*
    

ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
WORKDIR /workspace
CMD ["/bin/bash"]
