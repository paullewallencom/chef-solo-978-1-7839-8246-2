FROM linux/chef-solo
MAINTAINER Naveed "navidurrahman@gmail.com"

RUN apt-get -y update
RUN apt-get -y install python-software-properties
RUN apt-get -y update

ADD ./Berksfile /Berksfile
ADD ./solo.rb /var/chef/solo.rb
ADD ./solo.json /var/chef/solo.json

RUN cd / && /opt/chef/embedded/bin/berks install --path /var/chef/cookbooks
RUN chef-solo -c /var/chef/solo.rb -j /var/chef/solo.json
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

CMD ["nginx"]
