FROM      nginx
RUN       rm -rf /usr/share/nginx-conf/html /etc/nginx-conf/conf.d/default.conf
ADD       html /usr/share/nginx/html
ADD       docker.conf /etc/nginx/conf.d/default.conf