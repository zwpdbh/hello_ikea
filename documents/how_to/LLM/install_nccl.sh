#!/bin/bash

set -e

echo "📦 NVIDIA NCCL Installation Script for Ubuntu 22.04 (x86_64)"
echo "=========================================================="

# ---- Configurable options ----
REQUIRED_GLIBC="2.17"
DISTRO="ubuntu2204"
ARCH="x86_64"
NCCL_VERSION=""  # e.g. set to "2.18.3-1+cuda12.2" to pin, leave empty for latest

# ---- Step 1: Prerequisites check ----
echo "🧪 Checking system prerequisites..."

GLIBC_VERSION=$(ldd --version | head -n1 | awk '{print $NF}')
CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $6}' | cut -c2-)

if [[ "$(printf '%s\n' "$REQUIRED_GLIBC" "$GLIBC_VERSION" | sort -V | head -n1)" == "$REQUIRED_GLIBC" ]]; then
  echo "✅ glibc version $GLIBC_VERSION (OK)"
else
  echo "❌ glibc version $GLIBC_VERSION is too old. Required: >= $REQUIRED_GLIBC"
  exit 1
fi

if [[ -z "$CUDA_VERSION" ]]; then
  echo "❌ CUDA is not installed or 'nvcc' not found in PATH"
  exit 1
elif [[ $(printf '%s\n' "10.0" "$CUDA_VERSION" | sort -V | head -n1) != "10.0" ]]; then
  echo "✅ CUDA version $CUDA_VERSION (OK)"
else
  echo "❌ CUDA version $CUDA_VERSION is too old. Required: >= 10.0"
  exit 1
fi

# ---- Step 2: Add NVIDIA CUDA NCCL repository ----
echo "📥 Setting up NVIDIA CUDA repository for NCCL..."

KEYRING_DEB="cuda-keyring_1.0-1_all.deb"
if [ ! -f "$KEYRING_DEB" ]; then
  wget "https://developer.download.nvidia.com/compute/cuda/repos/${DISTRO}/${ARCH}/${KEYRING_DEB}"
fi

sudo dpkg -i "$KEYRING_DEB"
sudo apt-get update

# ---- Step 3: Install NCCL ----
echo "📦 Installing NCCL libraries..."

if [[ -z "$NCCL_VERSION" ]]; then
  sudo apt-get install -y libnccl2 libnccl-dev
else
  echo "📌 Installing pinned NCCL version: $NCCL_VERSION"
  sudo apt-get install -y "libnccl2=$NCCL_VERSION" "libnccl-dev=$NCCL_VERSION"
fi

# ---- Step 4: Verify installation ----
echo "🔍 Verifying installation..."
ldconfig -p | grep nccl || echo "⚠️  libnccl.so.* not found in system linker paths"

echo "✅ NCCL installation completed successfully."