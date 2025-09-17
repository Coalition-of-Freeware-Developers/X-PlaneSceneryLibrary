#!/usr/bin/env bash
set -euo pipefail

echo "[X-PlaneSceneryLibrary] Container CI build starting..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build-ci"

mkdir -p "${BUILD_DIR}"
pushd "${BUILD_DIR}" >/dev/null

BUILD_TYPE=${BUILD_TYPE:-Release}

echo "Configuring with CMake (Ninja generator)"
cmake -G Ninja "${ROOT_DIR}" \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DXPLIB_BUILD_TESTS=OFF \
  -DXPLIB_CI_MODE=ON \

echo "Building..."
cmake --build . --config Release -- -k 0

echo "[X-PlaneSceneryLibrary] CI build completed successfully."
