#!bin/bash
conda env create --name pytorchm1
conda activate pytorchm1

export M1_PYTORCH_VERSION="nightly"
echo "Installing c++ compiler and common os dependencies"
brew install gcc
conda install -y astunparse numpy ninja pyyaml setuptools cmake cffi typing_extensions future six requests dataclasses
echo "Adding additional dependencies for torch.distributed"
conda install -y pkg-config libuv

echo "Downloading torchvision source..."
mkdir packages && cd packages
git clone --recursive https://github.com/pytorch/vision.git torchvision

echo "Downloading torchaudio source..."
git clone --recursive https://github.com/pytorch/audio.git torchaudio

echo "Downloading pytorch source..."
git clone --recursive https://github.com/pytorch/pytorch pytorch

echo "Installing pytorch. Building ${M1_PYTORCH_VERSION} version"
cd pytorch
git submodule sync
git submodule update --init --recursive --jobs 0
# checkout the nightly branch of pytorch
git checkout $M1_PYTORCH_VERSION
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
MACOSX_DEPLOYMENT_TARGET=10.9 CC=clang CXX=clang++ USE_MPS=1 USE_PYTORCH_METAL=1 python setup.py install
echo "Pytorch installation complete!"

cd ../torchaudio
echo "Installing torchaudio...."
# install pending torchaudio dependencies
brew install pkg-config
# move to your torch audio repo and install
CC=clang CXX=clang++ python setup.py install

echo "Installing torchvision"
cd ../torchvision
conda install -y -c conda-forge ffmpeg
conda install -y pillow
MACOSX_DEPLOYMENT_TARGET=10.9 CC=clang CXX=clang++ python setup.py install

echo "Installation complete!"
