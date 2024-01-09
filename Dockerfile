FROM ubuntu:22.04

ENV TARGET=arm
#ENV TARGET=x86_64

RUN apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y git && \
  apt-get install -y make && \
  apt-get install -y curl && \
  apt-get install -y xz-utils && \
  apt-get install -y file && \
  apt-get install -y sudo && \
  apt-get install -y mecab && \
  apt-get install -y libmecab-dev && \
  apt-get install -y mecab-ipadic-utf8

# install の「-a」オプションは全部入り辞書の指定．これによりイメージが200MB程度大きくなる．
RUN mkdir /work && \
  cd /work && \
  git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
  cd mecab-ipadic-neologd && \
  # ./bin/install-mecab-ipadic-neologd -n -y && \
  ./bin/install-mecab-ipadic-neologd -n -a -y && \
  echo dicdir = `mecab-config --dicdir`"/mecab-ipadic-neologd">/etc/mecabrc && \
  sudo cp /etc/mecabrc /usr/local/etc && \
  cd .. && \
  rm -rf mecab-ipadic-neologd

RUN mkdir -p /work/crf && \
  mkdir -p /work/cabocha && \
  cd /work/crf && \
  curl -X GET -L 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ' -o CRF++-0.58.tar.gz && \
  tar xvzf CRF++-0.58.tar.gz && \
  cd CRF++-0.58 && \
  ./configure --build=${TARGET} && \
  make && \
  sudo make install && \
  sudo ldconfig && \
  cd ../../ && \
  rm -rf crf

RUN cd /work/cabocha && \
  FILE_ID=0B4y35FiV1wh7SDd1Q1dUQkZQaUU && \
  FILE_NAME=cabocha-0.69.tar.bz2 && \
  curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${FILE_ID}" > /dev/null && \
  CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)" && \
  curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=${FILE_ID}" -o ${FILE_NAME} && \
  tar xvjf cabocha-0.69.tar.bz2 && \
  cd cabocha-0.69 && \
  ./configure --with-charset=UTF8 --build=${TARGET} && \
  make && \
  sudo make install && \
  cd / && \
  rm -rf /work

CMD ["/usr/bin/mecab"]
