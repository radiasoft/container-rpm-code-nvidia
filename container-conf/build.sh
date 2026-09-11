#!/bin/bash
#
# rpm-code plus the CUDA toolkit and the gcc it accepts, for building
# the rscode-*-nvidia rpms. Not a runtime image.
#
build_image_base=radiasoft/rpm-code
build_is_public=
build_no_clean=1

# CUDA 13 dropped sm_70 (Volta) codegen, and fedora41 is the newest NVIDIA
# repo shipping CUDA 12.
_rpm_code_nvidia_cuda_repo=https://developer.download.nvidia.com/compute/cuda/repos/fedora41/x86_64/cuda-fedora41.repo

declare -a _rpm_code_nvidia_rpms=(
    cuda-toolkit-12-9
    # CUDA 12.9 rejects a host compiler newer than gcc 14
    gcc14
    gcc14-c++
)

_rpm_code_nvidia_cuda_math_h() {
    # glibc 2.42 (Fedora 43) declares cospi, sinpi, rsqrt and their float
    # variants noexcept, and CUDA 12.9 does not, so every .cu fails to compile
    perl -pi -w -e '
    BEGIN { $c = 0 }
    $c += s{^(?!.*noexcept)(extern .*\b(?:cospi|sinpi|rsqrt)f?\(.*\));}{$1 noexcept(true);};
    END { $c == 6 or die("expected 6 declarations, patched $c\n") }
    ' /usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h
}

build_as_root() {
    install_yum_add_repo "$_rpm_code_nvidia_cuda_repo"
    install_yum_install "${_rpm_code_nvidia_rpms[@]}"
    _rpm_code_nvidia_cuda_math_h
}
