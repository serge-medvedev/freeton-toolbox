FROM ubuntu:18.04

ARG EXTERNAL_UID=1000
ARG EXTERNAL_GID=1000
ARG TARGET_REPO=net.ton.dev

ENV TARGET_REPO=$TARGET_REPO
ENV TOP_DIR /opt/$TARGET_REPO

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo ca-certificates git curl rsync netcat iproute2 \
    && rm -fr /var/lib/apt/lists/* \
    && mkdir -p "$TOP_DIR" \
    && git clone "https://github.com/tonlabs/$TARGET_REPO.git" "$TOP_DIR" \
    && cd "$TOP_DIR/scripts" \
    && ./build.sh

WORKDIR "$TOP_DIR/scripts"

RUN sed -i 's/TON_WORK_DIR=".*"/TON_WORK_DIR="\/var\/ton\/work"/g' env.sh \
    && sed -i 's/ADNL_PORT="30310"/ADNL_PORT="30303"/g' env.sh

COPY entrypoint.sh .
COPY getstats.sh .

RUN groupadd -f -g $EXTERNAL_GID freeton \
    && useradd -MN -u $EXTERNAL_UID -g $EXTERNAL_GID -G sudo freeton \
    && echo 'freeton ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/freeton \
    && chown -R freeton:freeton "$TOP_DIR"

EXPOSE 30303/udp

USER freeton

ENTRYPOINT ["./entrypoint.sh"]

