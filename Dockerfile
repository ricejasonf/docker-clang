FROM ricejasonf/cppdock
MAINTAINER Jason Rice

RUN apt-get update
&&  apt-get -y install \
      curl tar xz-utils build-essential

WORKDIR /usr/local/src

# clang master
RUN git clone -b master https://github.com/llvm-mirror/llvm.git \
  && cd llvm/tools/ \
  && git clone -b master https://github.com/llvm-mirror/clang.git clang \
  && cd clang/tools \
  && git clone https://github.com/mikael-s-persson/templight.git \
  && cd .. \
  && patch -p0 tools/templight/templight_clang_patch.diff \
  && echo "add_subdirectory(templight)" >> CMakeLists.txt \
  && cd ../../../projects \
  && git clone https://github.com/llvm-mirror/libcxx.git \
  && git clone https://github.com/llvm-mirror/libcxxabi.git \
  && cd ../ && mkdir build && cd build \
  && cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_INCLUDE_EXAMPLES=OFF -DCLANG_INCLUDE_TESTS=OFF \
    .. \
  && make -j4 && make install \
  && cd /usr/local/src && rm -rf ./llvm

ENV CC=/usr/local/bin/clang \
    CXX=/usr/local/bin/clang++ \
    LD_LIBRARY_PATH=/usr/local/lib
