FROM archlinux:base-devel AS builder

WORKDIR /home
RUN pacman -Sy --noconfirm cmake git

ADD . /home/aura-bot

RUN cd aura-bot/StormLib \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_DYNAMIC_MODULE=1 .. \
    && make \
    && sudo make install  \
    && cd ../.. \
    && cd bncsutil/src/bncsutil \
    && make \
    && sudo make install \
    && cd ../../.. \
    && make 
    
RUN cd aura-bot \ 
    && sudo make install

FROM archlinux:base 
WORKDIR /srv/aura
COPY --from=builder /usr/bin/aura++ /srv/aura/aura++
COPY --from=builder /usr/lib/libbncsutil.so /usr/lib/libbncsutil.so
COPY --from=builder /usr/local/lib/libstorm.so /usr/lib/libstorm.so
COPY --from=builder /usr/local/lib/libstorm.so.9 /usr/lib/libstorm.so.9
COPY --from=builder /usr/local/lib/libstorm.so.9.21.0 /usr/lib/libstorm.so.9.21.0

CMD ["/srv/aura/aura++"]