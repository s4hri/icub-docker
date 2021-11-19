ARG DOCKER_SRC

FROM $DOCKER_SRC

LABEL maintainer="Davide De Tommaso <davide.detommaso@iit.it>"

ARG ICUBMAIN_TAG_VER=""
ARG ICUB_DIR="/home/docky/robotology-build"

USER root

ARG ICUB_PARAMS="-DENABLE_icubmod_cartesiancontrollerclient=ON  \
                 -DENABLE_icubmod_cartesiancontrollerserver=ON \
                 -DENABLE_icubmod_gazecontrollerclient=ON \
                 -DICUB_USE_ODE=ON \
                 -DICUB_USE_SDL=ON \
                 -DYARP_DIR=$YARP_DIR \
                 -DCMAKE_INSTALL_PREFIX=${ICUB_DIR}"

RUN apt-get install -y protobuf-compiler

USER docky

RUN cd /home/docky && \
    git clone https://github.com/robotology/icub-main.git -b $ICUBMAIN_TAG_VER && \
    cd icub-main && \
    mkdir build && \
    cd build  && \
    cmake .. $ICUB_PARAMS && \
    make -j$(nproc) && \
    make install;

ENV ICUB_DIR ${ICUB_DIR}
ENV YARP_DATA_DIRS=${ICUB_DIR}/share/iCub:${YARP_DATA_DIRS}
ENV PATH ${ICUB_DIR}/bin:$PATH

RUN cd /home/docky/ && \
    git clone https://github.com/robotology/icub-contrib-common.git && \
    cd icub-contrib-common && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${ICUB_DIR} && \
    make install;

ENV YARP_DATA_DIRS=${YARP_DATA_DIRS}:${ICUB_DIR}/share/ICUBcontrib
ENV QT_LOGGING_RULES "*=false"

RUN cd $HOME &&\
    git clone https://github.com/robotology/speech.git &&\
    cd speech && mkdir build && cd build &&\
    cmake .. -DCMAKE_INSTALL_PREFIX=${YARP_DIR} -DBUILD_SVOX_SPEECH=ON &&\
    make -j$(nproc) &&\
    make install

RUN cd /home/docky/ && \
    git clone https://github.com/s4hri/human-sensing.git && \
    cd human-sensing/faceLandmarks && \
    mkdir build && cd build && \
    cmake .. -DDOWNLOAD_FACE_LANDMARKS_DAT=ON && \
    make -j$(nproc) && \
    make install;

COPY init.sh ${HOME}
