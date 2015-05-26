FROM     ubuntu:14.04
RUN      echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/wheezy-backports.list
RUN      apt-get update && apt-get install -y curl
RUN      apt-get install -y --force-yes -t wheezy-backports nodejs
RUN      update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100
RUN      curl https://www.npmjs.com/install.sh | sh
RUN      npm install --global body-parser@1.9.0 compression@1.1.0 cors@2.4.2 errorhandler@1.2.0 express@4.9.5 multer@0.1.4
ENV      NODE_PATH=/usr/lib/node_modules
ADD      src /root/specref
WORKDIR  /root/specref
CMD      node index.js
