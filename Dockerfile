from ruby:2.7.2-alpine3.13

RUN apk update && \
 apk add --virtual build-dependencies cmake curl git jq make && \
 apk add boost-dev g++ gcc gd-dev libid3tag-dev libmad-dev libsndfile-dev && \
 git clone -n https://github.com/bbc/audiowaveform.git && \
 cd audiowaveform && \
 git checkout ${commit} && \
 curl -fL# https://github.com/google/googletest/archive/refs/tags/release-1.10.0.tar.gz -o googletest.tar.gz && \
 tar -xf googletest.tar.gz && \
 ln -s google*/google* . && \
 mkdir build && \
 cd build && \
 cmake .. && \
 cd ../build && \
 make -j $(nproc) && \
 make install && \
 apk del build-dependencies && \
 rm -rf /var/cache/apk/* && \
 rm -rf /audiowaveform

# entrypoint ["audiowaveform"]
# cmd ["--help"]

RUN apk add pulseaudio pulseaudio-utils

ENV APP_HOME /tapp

RUN mkdir -p $APP_HOME
ADD Gemfile Gemfile.lock $APP_HOME

WORKDIR $APP_HOME
RUN bundle install

ADD . $APP_HOME

entrypoint ["/bin/ash"]
