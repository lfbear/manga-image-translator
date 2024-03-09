FROM pytorch/pytorch:latest

WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
# Assume root to install required dependencies
RUN apt-get update && \
    apt-get install -y git g++ ffmpeg libsm6 libxext6 libvulkan-dev wget curl vim

#RUN pip install git+https://github.com/lucasb-eyer/pydensecrf.git
RUN conda install -c conda-forge pydensecrf
# Install pip dependencies

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt
RUN pip install torchvision --force-reinstall

# RUN apt-get remove -y g++ && \
#     apt-get autoremove -y

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb
RUN apt-get update
RUN apt-get -y install cuda

# Copy app
COPY . /app

# Prepare models
RUN python -u docker_prepare.py

RUN rm -rf /tmp

# Add /app to Python module path
ENV PYTHONPATH="${PYTHONPATH}:/app"

WORKDIR /app

ENTRYPOINT ["python", "-m", "manga_translator"]
