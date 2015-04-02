FROM sjeanpierre/hubot-centos


COPY hubot /var/hubot/bin/
WORKDIR /var/hubot/

CMD ["./bin/hubot"]

