FROM sjeanpierre/hubot-centos66


COPY hubot /var/hubot/bin/
WORKDIR /var/hubot/

CMD ["./bin/hubot"]

