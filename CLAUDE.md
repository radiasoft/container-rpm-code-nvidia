# container-rpm-code-nvidia

This image is the build container for the CUDA variants of the code rpms. It is
`radiasoft/rpm-code` (which is `radiasoft/fedora` plus `rscode-common`) plus the
CUDA toolkit and the gcc that toolkit accepts. Nothing here is a runtime image:
it holds `nvcc` so `rpm-code` can compile `rscode-amrex-nvidia`,
`rscode-pyamrex-nvidia`, and `rscode-warpx-nvidia`. The rpms it produces are
installed into `radiasoft/jupyter-nvidia`, which needs the CUDA runtime
libraries added separately -- torch's copies live inside the wheel's `nvidia/*`
directories and are not on the system link path.

Background and the GPU host setup are in the devsecops wiki page
[GPU-Jupyter-by-AI](https://github.com/radiasoft/devsecops/wiki/GPU-Jupyter-by-AI).

## To do

Write `container-conf/build.sh`. Model it on container-rpm-code's, with
`build_image_base=radiasoft/rpm-code`, and install:

- the CUDA toolkit, from NVIDIA's fedora41 repo
- `gcc14` and `gcc14-c++`

Then in radiasoft/download:

- `installers/rpm-code/radiasoft-download.sh`: `rpm_code_is_nvidia` selects this
  image the way `rpm_code_is_common` selects `radiasoft/fedora`
- `installers/rpm-code/codes.sh`: `codes_run_main` sources another code's script
  and calls its main (`install_script_eval` always calls main, so it cannot be
  used), and `codes_nvidia_module` appends the `-nvidia` suffix to dependency
  names
- `installers/rpm-code/codes/{amrex,pyamrex,warpx}-nvidia.sh`: each sets
  `codes_is_nvidia=1`, overrides the version, and calls `codes_run_main`

## Constraints

These are settled; do not rederive them.

- The oldest GPUs that must keep working are Volta, `sm_70`. CUDA 13 dropped
  `sm_70` codegen, so the toolkit is CUDA 12.x.
- NVIDIA's fedora43 repo ships only `cuda-toolkit-13-x`. fedora41 is the newest
  Fedora repo with CUDA 12 (through 12-9).
- CUDA 12.9 rejects a host gcc newer than 14, and Fedora 43 has gcc 15. Rather
  than `nvcc -allow-unsupported-compiler`, the builds pass
  `-D CMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-14`, and set `CMAKE_C_COMPILER` and
  `CMAKE_CXX_COMPILER` to 14 as well so every object comes from one compiler.
- A GPU is not needed to build; `nvcc` cross-compiles for `sm_70`. Only running
  the result needs the hardware.
- impactx holds amrex at an older version than warpx wants, so the version pin
  lives in both the base script and the `-nvidia` script. The base uses
  `: ${amrex_version:=...}` so the variant can override it.
