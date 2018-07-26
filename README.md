# caffe-ssd-py3-opencv
Dockerfile for [SSD version of Caffe](https://github.com/weiliu89/caffe) using OpenCV 3.2. with python3

# Prerequisites 
CUDA 8.0 enabled driver and 
[Nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

# How to use 
```script
nvidia-docker run -ti votiethuy/caffe-ssd-py3-opencv-gpu-docker caffe
```

Or in interactive mode
```script
nvidia-docker run -ti votiethuy/caffe-ssd-py3-opencv-gpu-docker bash
```
