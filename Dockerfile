FROM debian:11 AS builder
RUN sed -i "s@http://.*.debian.org@http://repo.huaweicloud.com@g" /etc/apt/sources.list
# install build tools
RUN apt update && apt install -y git make g++ m4 zlib1g-dev subversion wget unzip

FROM builder AS builder-gmp
RUN apt update && apt install -y libgmp-dev

FROM builder-gmp AS builder-gmp-ecm
RUN apt update && apt install -y gmp-ecm libecm1-dev

FROM builder-gmp-ecm AS builder-gmp-ecm-msieve
# download source code
RUN svn co https://svn.code.sf.net/p/msieve/code/trunk /msieve
# build
RUN cd /msieve && make all ECM=1 NO_ZLIB=1
RUN /msieve/msieve -v 115367564564210182766242534110944507919869313713243756429

FROM builder AS builder-lasieve4
RUN wget https://st0n3-dev.obs.cn-south-1.myhuaweicloud.com/yafu/gnfs-lasieve_2010-11-18.zip
RUN mkdir -p /ggnfs && unzip -d /ggnfs gnfs-lasieve_2010-11-18.zip

FROM builder AS ytools
# download source code
RUN git clone https://github.com/bbuhrow/ytools.git
# build 
RUN cd /ytools && sed -i s/gcc-7.3.0/gcc/g Makefile && make

FROM builder-gmp AS ysieve
COPY --from=ytools /ytools /ytools
# download source code
RUN git clone https://github.com/bbuhrow/ysieve
# build
RUN cd /ysieve && make

FROM builder-gmp-ecm-msieve AS yafu
COPY --from=ytools /ytools /ytools
COPY --from=ysieve /ysieve /ysieve
COPY --from=builder-lasieve4 /ggnfs /ggnfs
RUN git clone https://github.com/bbuhrow/yafu.git
WORKDIR /yafu
RUN sed -i 's@/users/buhrow/src/c/gmp_install/gmp-6.2.0/lib/libgmp.a@/usr/lib/x86_64-linux-gnu/libgmp.a@g' Makefile && \
    sed -i 's@ggnfs_dir=..\\..\\ggnfs-bin\\x64\\@ggnfs_dir=/ggnfs@g' yafu.ini && \
    sed -i 's@ecm_path=..\\..\\gmp-ecm\\bin\\mingw\\ecm.exe@ecm_path=/usr/bin/ecm@g' yafu.ini
RUN make NFS=1

FROM debian:11 AS release
RUN sed -i "s@http://.*.debian.org@http://repo.huaweicloud.com@g" /etc/apt/sources.list
RUN apt update && apt install -y gmp-ecm libecm1-dev
COPY --from=yafu /yafu/yafu /usr/local/bin/yafu
