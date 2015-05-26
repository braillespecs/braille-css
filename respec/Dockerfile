FROM     ubuntu:14.04
RUN      echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/wheezy-backports.list
RUN      apt-get update && apt-get install -y curl apache2 phantomjs
RUN      apt-get install -y --force-yes -t wheezy-backports nodejs
RUN      update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100
RUN      curl https://www.npmjs.com/install.sh | sh
RUN      npm install --global express@3.1.0 requirejs@2.1.8
ENV      NODE_PATH=/usr/lib/node_modules
ADD      src /root/respec
ADD      respec2html /bin/respec2html
RUN      chmod +x /bin/respec2html
WORKDIR  /root/respec
RUN      node tools/build-w3c-common.js
RUN      cp builds/respec-w3c-common.js /var/www/html/
CMD      service apache2 start && tail -f /var/log/apache2/access.log
