FROM sjeanpierre/hubot-centos


COPY hubot /var/hubot/bin/
WORKDIR /var/docker/

CMD ["./bin/hubot", "--adapter slack"]

