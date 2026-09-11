# RadiaSoft rpm-code-nvidia Docker Image (radiasoft/rpm-code-nvidia)

[rpm-code](https://github.com/radiasoft/container-rpm-code) with the CUDA
toolkit added.

This is an intermediate container, used by
[rpm-code](https://github.com/radiasoft/download/tree/master/installers/rpm-code)
to build the CUDA variants of the code rpms (`rscode-*-nvidia`). It is not a
runtime image; those rpms are installed into
[jupyter-nvidia](https://github.com/radiasoft/container-jupyter-nvidia).

See download/installers/rpm-code/README.md for how to develop.
