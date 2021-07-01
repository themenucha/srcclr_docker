FROM registry.access.redhat.com/ubi8/ubi:latest
ENV container=docker

# Silence annoying subscription messages.
RUN echo "enabled=0" >> /etc/yum/pluginconf.d/subscription-manager.conf

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install Runtimes and package managers aviable with yum.
RUN yum makecache --timer \
 && yum -y install initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      make \
      which \
      zip \
      hostname \
      python3 \
      python2 \
      java-openjdk \
      maven \
      npm \
      gem \
      git \
      python2-pip \
      python3-pip \
      jq \
      vim \
      golang \
 && yum clean all
WORKDIR	/home/app
# Install additional package managers and other dependancies
# js
# Setup yarn, bower 
RUN touch ~/.bashrc
RUN cd $HOME && curl -o- -L https://yarnpkg.com/install.sh | bash 
RUN npm install -g bower
# Golang
# Setup Go: GOPATH, govendor, dep, godep, trash
ENV GOPATH=$HOME/go 
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin 
RUN go get -u github.com/kardianos/govendor
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | bash 
RUN go get github.com/tools/godep 
RUN go get -u github.com/rancher/trash
ADD	sdkman-init.sh /root/sdkman-init.sh
# Java
# Install gradle, ant via sdkman-init.sh
RUN curl -s "https://get.sdkman.io" | bash 
RUN chmod +x /root/sdkman-init.sh
RUN  cd /root && ./sdkman-init.sh
# Python
# Setup pipenv
RUN pip2 install pipenv
RUN pip3 install pipenv
# Ruby
#Setup bundler
RUN gem install bundler
RUN  mkdir -p /home/app/.srcclr/scans/ && \
        npm -g install shrinkwrap && \
	rm -rf /var/lib/apt/lists/*

# Install srcclr 
RUN	curl -JLO https://download.srcclr.com/srcclr-$(curl -sf https://download.srcclr.com/LATEST_VERSION)-linux.tgz && \
	tar -xzf srcclr-*.tgz && rm srcclr-*.tgz && mv srcclr-* srcclr

ENTRYPOINT ["sleep","infinity"]
