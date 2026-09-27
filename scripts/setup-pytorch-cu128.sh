#!/bin/bash
# Setup script for DJL PyTorch 2.7.1 with CUDA 12.8 (cu128)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LIBTORCH_PATH="$PROJECT_DIR/lib/libtorch-2.7.1/lib"

# Check if libtorch exists
if [ ! -d "$LIBTORCH_PATH" ]; then
    echo "Error: libtorch not found at $LIBTORCH_PATH"
    return 1 2>/dev/null || exit 1
fi

# Create libcudart.so symlink if missing
if [ ! -e "$LIBTORCH_PATH/libcudart.so" ]; then
    CUDART_FILE=$(ls "$LIBTORCH_PATH"/libcudart.so.* "$LIBTORCH_PATH"/libcudart-*.so.* 2>/dev/null | head -1)
    if [ -n "$CUDART_FILE" ]; then
        ln -sf "$(basename "$CUDART_FILE")" "$LIBTORCH_PATH/libcudart.so"
        echo "Created symlink: libcudart.so -> $(basename "$CUDART_FILE")"
    fi
fi

# Remove Python-dependent libraries that break JNI loading
if [ -f "$LIBTORCH_PATH/libtorch_python.so" ]; then
    rm -f "$LIBTORCH_PATH/libtorch_python.so"
    echo "Removed libtorch_python.so (Python dependency)"
fi

if [ -f "$LIBTORCH_PATH/libnnapi_backend.so" ]; then
    rm -f "$LIBTORCH_PATH/libnnapi_backend.so"
    echo "Removed libnnapi_backend.so (Python dependency)"
fi

# DJL eagerly loads every .so in this directory. The optional GPUDirect
# RDMA plugin requires Mellanox libraries that ordinary CUDA training does not.
# Keep it outside the load directory when those dependencies are unavailable.
for rdma_lib in "$LIBTORCH_PATH"/libcufile_rdma*.so*; do
    if [ -f "$rdma_lib" ] && ldd "$rdma_lib" 2>/dev/null | grep -q 'not found'; then
        mkdir -p "$LIBTORCH_PATH/../optional"
        mv "$rdma_lib" "$LIBTORCH_PATH/../optional/"
        echo "Moved optional RDMA plugin to $LIBTORCH_PATH/../optional/"
    fi
done

# Export environment variables
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=$LIBTORCH_PATH:$LD_LIBRARY_PATH
export PYTORCH_LIBRARY_PATH=$LIBTORCH_PATH
export PYTORCH_VERSION=2.7.1
export PYTORCH_FLAVOR=cu128

# Set JNA library path for sbt (so it finds the bundled cudart)
export SBT_OPTS="${SBT_OPTS} -Djna.library.path=$LIBTORCH_PATH"

echo ""
echo "GPU environment configured:"
echo "  PYTORCH_LIBRARY_PATH=$PYTORCH_LIBRARY_PATH"
echo "  PYTORCH_VERSION=$PYTORCH_VERSION"
echo "  PYTORCH_FLAVOR=$PYTORCH_FLAVOR"
echo "  SBT_OPTS includes -Djna.library.path"
echo ""
echo "To run with GPU:"
echo "  source $SCRIPT_DIR/setup-pytorch-cu128.sh"
echo "  sbt --server 'rlLogicJVM/testOnly cps.rl.examples.tiktaktoe.TikTakToeTrainingTest'"
