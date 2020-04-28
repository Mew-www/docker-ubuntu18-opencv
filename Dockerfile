FROM ubuntu:18.04

# Set opencv version, default currently latest (explicitly numbered)
ARG OPENCV_RELEASE=4.3.0
# Version specific opencv build flags, https://github.com/opencv/opencv/blob/4.3.0/CMakeLists.txt & module disables
# Optionally set them as "-D BUILD_OPTION=ON -D BUILD_opencv_module=OFF"
ARG ADDITIONAL_BUILD_FLAGS
# Optionally set to any value (1, "true", anything but emptystring) to enable GUI features
ARG ENABLE_IMSHOW_AND_WAITKEY

# Install build tools
RUN apt-get update && \
    apt-get install -y wget unzip build-essential cmake

# Optional dependencies for GUI features
# Using cv.imshow() or cv.waitkey() requires sharing xserver with docker:
#> running `xhost local:root` on host machine (before docker run); later remove with `xhost -local:root`
#> using following docker run flags: --network=host -e DISPLAY=$DISPLAY
RUN if [ -n "${ENABLE_IMSHOW_AND_WAITKEY}" ]; then apt-get install -y libgtk2.0-dev pkg-config; fi;

# Build OpenCV
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_RELEASE}.zip -O opencv.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_RELEASE}.zip -O contrib.zip && \
    unzip opencv.zip && \
    unzip contrib.zip && \
    mkdir build && \
    cd build && \
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${OPENCV_RELEASE}/modules \
        -D BUILD_JAVA=OFF \
        ${ADDITIONAL_BUILD_FLAGS} \
        ../opencv-${OPENCV_RELEASE} && \
    make -j5 && \
    make install

CMD ["bash"]
