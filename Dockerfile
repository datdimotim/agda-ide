FROM haskell:8.8.3 AS builder

# UPDATE for new version
ARG agda_version=2.6.1
ARG agda_stdlib_version=1.3
ARG ghc_version=8.8.3

# Workaround for a Happy bug/misfeature. With the default locale, Happy does
# not recognise UTF-8 files.
ENV LC_ALL=C.UTF-8

# install Agda
RUN git clone --depth 1 -b "v${agda_version}" https://github.com/agda/agda.git /root/.agda/src
RUN stack --stack-yaml /root/.agda/src/stack-"${ghc_version}".yaml install
RUN stack --stack-yaml /root/.agda/src/stack-"${ghc_version}".yaml clean

# UPDATE for new version
ARG agda_stdlib_version=1.3

# get agda-stdlib sources
RUN mkdir -p /root/.agda/lib
RUN git clone --depth 1 -b "v${agda_stdlib_version}" https://github.com/agda/agda-stdlib.git /root/.agda/lib/standard-library

# generate agda-stdlib's Everything.hs
WORKDIR /root/.agda/lib/standard-library
RUN stack --resolver "ghc-${ghc_version}" script --package filemanip --package filepath --package unix-compat --package directory --system-ghc -- GenerateEverything.hs

# generate .agdai files for agda-stdlib
WORKDIR /root/.agda/lib/standard-library
RUN mv Everything.agda src/
RUN agda --verbose=0 src/Everything.agda
RUN mv src/Everything.agda .
RUN rm _build/${agda_version}/agda/src/Everything.agdai







# UPDATE for new version
FROM haskell:8.8.3

# UPDATE for new version
ARG agda_version=2.6.1
ARG agda_stdlib_version=1.3
ARG ghc_version=8.8.3
ARG snapshot_hash=1e00b9ab146f000e5939314a3f7d999792a6fde726b96f5a16d953eaba093987

# UPDATE for new version
ARG agda_version=2.6.1
ARG agda_stdlib_version=1.3
ARG ghc_version=8.8.3
ARG snapshot_hash=1e00b9ab146f000e5939314a3f7d999792a6fde726b96f5a16d953eaba093987




ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y curl gpg 

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
  && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
  && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# show available vscode versions
RUN echo "vs-code versions:" && apt-cache policy code

## Install vscode in the specifc version
RUN apt-get update && apt-get install -y code \
  && apt-get install -f

##############
# copy Agda binaries
COPY --from=builder /root/.local/bin/ /root/.local/bin/

# copy library files for Agda primitives
COPY --from=builder \
  /root/.agda/src/.stack-work/install/x86_64-linux/ \
  /root/.agda/src/.stack-work/install/x86_64-linux/

# copy libraries
COPY --from=builder /root/.agda/lib/ /root/.agda/lib/
##############


RUN useradd -ms /bin/bash vscode
RUN chown -R vscode /root

USER vscode
WORKDIR /home/vscode

# register agda-stdlib
COPY libraries /home/vscode/.agda/

# register agda-stdlib default
COPY defaults /home/vscode/.agda/

RUN code --install-extension banacorn.agda-mode
# fix open folder dialog
RUN export QT_X11_NO_MITSHM=1
CMD /bin/bash -c '/usr/bin/code --verbose --user-data-dir /userdata'
  
