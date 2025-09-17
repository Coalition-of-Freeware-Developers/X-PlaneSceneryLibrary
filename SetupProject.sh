#!/usr/bin/env bash
set -euo pipefail

# Quick Linux setup script for X-PlaneSceneryLibrary
# - Configures out-of-source build under ./build
# - Uses the local vcpkg manifest and toolchain
# - Builds library and tests

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
BUILD_DIR="${ROOT_DIR}/build"

echo "==> XPSceneryLib: Linux setup"
echo "Root: ${ROOT_DIR}"

mkdir -p "${BUILD_DIR}"
pushd "${BUILD_DIR}" >/dev/null

echo "==> Configuring CMake"
cmake .. \
  -DCMAKE_BUILD_TYPE=Debug

echo "==> Building XPSceneryLib (all targets)"
cmake --build . --config Debug -j

echo "==> Running tests (if built)"
ctest -C Debug --output-on-failure || true

echo "==> Artifacts under: ${ROOT_DIR}/bin/$(uname)/Debug"
popd >/dev/null

echo "Done."
