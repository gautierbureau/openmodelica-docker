FROM fedora:29 as builder

ARG VERSION

RUN dnf upgrade -y \
&& dnf update -y \
&& dnf install -y \
  git \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  autoconf \
  automake \
  make \
  libtool \
  cmake \
  hwloc \
  java-1.8.0-openjdk-devel \
  blas-devel \
  lapack-devel \
  lpsolve-devel \
  expat-devel \
  glibc-devel \
  sqlite-devel \
  xerces-c-devel \
  libarchive-devel \
  zlib-devel \
  qt-devel \
  gettext \
  patch \
  wget \
  python-devel \
  clang \
  llvm-devel \
  ncurses-devel \
  readline-devel \
  unzip \
  perl-Digest-MD5 \
  vim \
  gcovr \
  python-pip \
  python-psutil \
  boost-devel \
  lcov \
  gtest-devel \
  gmock-devel \
  xz \
  rsync \
  python-lxml \
  graphviz \
  clang-devel \
  OpenSceneGraph-devel \
  qtwebkit \
  qtwebkit-devel \
  qt5-qtwebkit \
  qt5-qtwebkit-devel \
  qwt python-sphinx \
  qwt-devel \
  OpenSceneGraph-qt-devel \
  OpenSceneGraph-devel \
  OpenSceneGraph-libs \
  OpenSceneGraph-qt \
  OpenSceneGraph-qt-devel \
  qwt5-qt4-devel \
  glibc-static \
  libstdc++-static \
  omniORB-devel \
  poppler-devel \
  flex \
  bison \
  maven \
  curl-devel \
  uuid-devel \
  qt5-linguist \
  qt5-qtsvg-devel \
  qt5-qtxmlpatterns-devel \
  libffi-devel \
&& dnf clean all \
&& strip --remove-section=.note.ABI-tag /usr/lib64/libQt5Core.so.5 \
&& cd /opt \
&& mkdir OpenModelica && cd OpenModelica \
&& git clone --branch v1.16.2 --recursive https://github.com/OpenModelica/OpenModelica.git Source \
&& cd Source \
&& autoconf \
&& ./configure CC=clang CXX=clang++ --prefix=/opt/OpenModelica/Install QTDIR=/usr/lib64/qt5 --with-omniORB \
&& make -j 2 omedit \
&& make install \
&& cd /opt/OpenModelica/Install/lib \
&& rm -rf omlibrary \
&& modelicalib_version=3.2.3 \
&& modelicalib_url=https://github.com/modelica/ModelicaStandardLibrary/archive \
&& curl -L ${modelicalib_url}/v${modelicalib_version}.tar.gz -o v${modelicalib_version}.tar.gz \
&& tar xzf v${modelicalib_version}.tar.gz \
&& mkdir omlibrary \
&& mv ModelicaStandardLibrary-${modelicalib_version}/* omlibrary \
&& rm -rf ModelicaStandardLibrary-${modelicalib_version} v${modelicalib_version}.tar.gz

FROM fedora:29

RUN dnf upgrade -y \
&& dnf update -y \
&& dnf install -y \
  omniORB \
  lpsolve \
  lapack-devel \
  clang \
  make \
  qt5-qtwebkit \
  qt5-qtsvg \
  boost-filesystem \
  OpenSceneGraph-libs \
  openssh-server \
  xauth \
  sudo \
&& dnf clean all

COPY --from=builder /opt/OpenModelica /opt/OpenModelica

RUN echo 'root:pass' | chpasswd \
&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
&& ssh-keygen -A \
&& echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
&& echo 'export PATH=/opt/OpenModelica/Install/bin:$PATH' >> /etc/profile

EXPOSE 22

ENV PATH=/opt/OpenModelica/Install/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV QT_GRAPHICSSYSTEM=native