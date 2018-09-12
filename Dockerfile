FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        iputils-ping \ 
        telnet \
        vim &&\
    rm -rf /var/lib/apt/lists/*

# Install all dependencies for OpenCV 3.2
RUN apt-get -y update && apt-get -y install libssl-dev libffi-dev python3-dev python3-pip gfortran libgtk2.0-dev libavcodec-dev libavformat-dev libv4l-dev

RUN pip3 install --upgrade pip

RUN pip3 install numpy

WORKDIR /
ENV OPENCV_VERSION="3.4.2"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip

RUN mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=OFF \
  -DWITH_OPENCL=OFF \
  -DWITH_IPP=OFF \
  -DWITH_TBB=OFF \
  -DWITH_EIGEN=OFF \
  -DWITH_V4L=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3) \
  -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make -j8 \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}

ENV CAFFE_ROOT=/opt/caffe

ADD Makefile.config /opt

WORKDIR $CAFFE_ROOT

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH

RUN git clone https://github.com/weiliu89/caffe.git .

RUN git checkout ssd

RUN cp /opt/Makefile.config /opt/caffe/Makefile.config

RUN cd python && for req in $(cat requirements.txt) pydot; do pip3 install $req; done && cd ..

RUN apt-get install -y liblapack-dev liblapack3 libopenblas-base libopenblas-dev

RUN ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial.so.10.1.0 /usr/lib/x86_64-linux-gnu/libhdf5.so

RUN ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial_hl.so.10.0.2 /usr/lib/x86_64-linux-gnu/libhdf5_hl.so

RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py35.so /usr/lib/x86_64-linux-gnu/libboost_python3.so

RUN make -j8

RUN make py

RUN make test -j8

ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

RUN apt-get update -y && apt-get install -y libsm6 libxext6

RUN pip3 install --upgrade pip setuptools

ADD requirements.txt /usr/src/requirements.txt

RUN pip3 install -r /usr/src/requirements.txt

RUN RUN apt-get update -y && apt-get install -y swig