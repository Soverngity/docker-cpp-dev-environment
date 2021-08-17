# Ubuntu C++ 编译环境
FROM ubuntu:20.04

LABEL version="v1" \
      maintainer="ZiFan <njustcxp@gmail.com>"

#ARG BOOST_VERSION=1.73.0
#ARG BOOST_VERSION_=1_73_0
#ENV BOOST_VERSION=${BOOST_VERSION}
#ENV BOOST_VERSION_=${BOOST_VERSION_}
#ENV BOOST_ROOT=/usr/include/boost

ENV DEBIAN_FRONTEND=noninteractive

COPY sources.list /etc/apt/sources.list

RUN apt-get update

RUN apt install -y --no-install-recommends tzdata build-essential cmake gdb openssh-server rsync vim git wget

# config sshd
RUN mkdir /var/run/sshd
RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&  sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/g' /etc/default/rsync

# config rsync service
COPY rsync.conf /etc
RUN echo 'root:111' |chpasswd
RUN mkdir /root/sync
# install boost
#RUN wget --max-redirect 3 --no-check-certificate https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_}.tar.gz
#RUN mkdir -p /usr/include/boost && tar zxf boost_${BOOST_VERSION_}.tar.gz -C /usr/include/boost --strip-components=1 && rm *.tar.gz

# zsh
RUN apt install -y zsh
RUN git -c http.sslVerify=false clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && chsh -s /bin/zsh
RUN echo $SHELL

# 参考
# https://segmentfault.com/a/1190000015283092
# https://juejin.im/post/5cf34558f265da1b80202d75
# 安装 autojump 插件
RUN apt install -y autojump
# 安装 zsh-syntax-highlighting 插件
RUN git -c http.sslVerify=false clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# 安装 zsh-autosuggestions 插件
RUN git -c http.sslVerify=false clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN sed -ri 's/^plugins=.*/plugins=(git autojump zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# 删除 apt update 产生的缓存文件
# 因为 docker 的文件系统是层文件系统，上一个层中缓存有apt-get update的结果，
# 那么下次 Dockerfile 运行时就会直接使用之前的缓存，
# 这样 docker 中的 apt 软件源就不是最新的软件列表了，将会带来缓存过期的问题。
# 并且这些缓存将占用不少空间，导致最终生成的image非常庞大，
# 而这些垃圾文件是我们最终的image中无需使用到的东西，我们应当在Docker构建过程中予以删除。
RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /sbin
RUN chmod +x /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
