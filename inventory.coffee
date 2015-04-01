# Description:
#   <looks up instances in our development, staging and production environments>
#
#
# Configuration:
#   HUBOT_HTTP_SERVICE
#
# Commands:
#   hubot whois `i-63ad3b9d` or `10.30.180.2` or `50.183.35.5` will return details about the instance
#
# Notes:
#   <this whois fuctionality is only for our instances not to be confused with the other whois>
#
# Author:
#   sjeanpierre

service_url = 172.17.42.1:9292

module.exports = (robot) ->
  robot.hear /whois ((?:[0-9]{1,3}\.){3}[0-9]{1,3}$|i-\w*)/i, (msg) ->
    identifier = escape(msg.match[1])
    data = "identifier=#{identifier}"
    msg.http("#{service_url}/inventory")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      result = JSON.parse(body)
      console.log result
      server = new Server(result)
      robot.emit 'slack.attachment',
        message: msg.message
        content:
          text: server.format_title()
          fallback: server.format()
          color: '#018DE4'
          fields: server.format_for_attachment()

  class Server
    constructor: (instance) ->
      @uid = instance.uid
      @account_id = instance.account_id
      @deployment_url = instance.deployment_url
      @name = instance.name
      @private_ip = instance.private_ip
      @public_ip = instance.public_ip

    format_for_attachment: ->
      formatted_fields = []
      fields = {uid: @uid, account_id: @account_id, private_ip: @private_ip, public_ip: @public_ip}
      for key,value of fields
        formatted_fields.push({
          "title": "#{key}",
          "value": "#{value}",
          "short": true
        })
      return formatted_fields


    format_title: ->
      "<#{@deployment_url}|#{@name}>"

    format: ->
      "*UID:* #{@uid}\n*Account ID:* #{@account_id}\n*Deployment URL:* #{@deployment_url}\n*Name:* #{@name}\n*Private IP:* #{@private_ip}\n*Public IP:* #{@public_ip}\n-----------------------"
