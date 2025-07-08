FROM ros:jazzy as ardupilot_gazebo

ARG GZ_VERSION=harmonic

RUN apt-get update --yes
RUN apt-get install --yes libopencv-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl curl lsb-release gnupg

RUN sh -c 'curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg'
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null'

RUN apt-get update --yes
RUN apt-get install --yes libgz-sim8-dev rapidjson-dev

COPY ./ ./ardupilot_gazebo
# RUN git clone https://github.com/ArduPilot/ardupilot_gazebo.git

WORKDIR ardupilot_gazebo/build

RUN cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN make -j4

RUN mkdir /plugins
RUN cp /ardupilot_gazebo/build/*.so /plugins

FROM scratch

COPY --from=ardupilot_gazebo /plugins /plugins

