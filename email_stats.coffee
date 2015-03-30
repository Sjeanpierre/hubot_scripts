service_url = #hubot_http_service_url

module.exports = (robot) ->
  robot.hear /show email stats for past (\d*) (days|weeks)/i, (msg) ->
    type = 'all'
    count = escape(msg.match[1])
    unit = escape(msg.match[2])
    data = "type=#{type}&count=#{count}&unit=#{unit}"
    msg.http("#{service_url}/email_stats")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      data = JSON.parse(body)
      processResponse(type, msg, data)

  robot.hear /show email (complaints|bounces|deliveries|stats) for ((1[0-2]|0?[1-9])\/(3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2})/i, (msg) ->
    type = escape(msg.match[1])
    date = escape(msg.match[2])
    data = "type=#{type}&date=#{date}"
    msg.http("#{service_url}/email_stats")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      data = JSON.parse(body)
      processResponse(type, msg, data)

  robot.hear /show email (complaints|bounces|deliveries|stats) between ((?:1[0-2]|0?[1-9])\/(?:3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2}) (?:and|&|&amp) ((?:1[0-2]|0?[1-9])\/(?:3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2})/i, (msg) ->
    console.log('Got the message')
    type = escape(msg.match[1])
    date1 = escape(msg.match[2])
    date2 = escape(msg.match[3])
    data = "type=#{type}&date1=#{date1}&date2=#{date2}"
    msg.http("#{service_url}/email_stats")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      data = JSON.parse(body)
      processResponse(type, msg, data)


  robot.hear /show email (complaints|bounces|deliveries) for past (\d*) (days|day|weeks|week)/i, (msg) ->
    type = escape(msg.match[1])
    count = escape(msg.match[2])
    unit = escape(msg.match[3])
    data = "type=#{type}&count=#{count}&unit=#{unit}"
    msg.http("#{service_url}/email_stats")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      data = JSON.parse(body)
      processResponse(type, msg, data)

  robot.hear /show email (complaints|bounces|deliveries|stats) for (.+\@.+\.\w+) (?:during|for) past (\d*) (days|day|weeks|week)/i, (msg) ->
    type = escape(msg.match[1])
    email = "#{escape(msg.match[2])}".split('%20')[0]
    count = escape(msg.match[3])
    unit = escape(msg.match[4])
    data = "type=#{type}&email=#{email}&count=#{count}&unit=#{unit}"
    msg.http("#{service_url}/email_stats")
    .headers(Accept: 'application/json')
    .post(data) (err, res, body) ->
      if res.statusCode isnt 200
        msg.send "#{JSON.parse(body).message}"
        return
      data = JSON.parse(body)
      processResponse(type, msg, data)


  processResponse = (type, msg, data) ->
    if type in ['all', 'stats']
      data = [data]
    for results in data
      response = dispatchType(type, results)
      robot.emit 'slack.attachment',
        message: msg.message
        content:
          text: response.format_title()
          fallback: response.format()
          color: '#018DE4'
          fields: response.format_for_attachment()


  dispatchType = (type, results) ->
    if type == 'complaints'
      new ComplaintMessage(results)
    else if type == 'bounces'
      new BouncedMessage(results)
    else if type == 'deliveries'
      new DeliveredMessage(results)
    else if type in ['stats', 'all']
      new StatMessage(results)

  class Message
    constructor: (message) ->
      @disposition = message.disposition
      @date = message.date
      @message_id = message.message_id
      @account = message.account
      @details = message.details
      @recipient = message.recipient
      @fields = {Status: @disposition, Date: @date, Message_id: @message_id, Account: @account, Recipient: @recipient}
      for key,val of @unique_fields
        @fields[key] = val


    format_for_attachment: ->
      formatted_fields = []
      for key,value of @fields
        formatted_fields.push({
          "title": "#{key}",
          "value": "#{value}",
          "short": true
        })
      return formatted_fields

    format_title: ->
      ''

    format: ->
      "*Status* #{@disposition}\n*Date* #{@date}\n*Message ID* #{@message_id}\n*account* #{@account}\n*Recipient* #{@recipient}\n"

  class BouncedMessage extends Message
    constructor: (message) ->
      @message_detail = message.details.bounce_details
      @unique_fields = {Bounce_type: @message_detail.bounce_type, Bounce_subtype: @message_detail.bounce_subtype, Bounce_reason: @message_detail.bounce_reason}
      super(message)

  class DeliveredMessage extends Message
    constructor: (message) ->
      @message_detail = message.details.delivery_details
      @unique_fields = {Processing_time: @message_detail.processing_time, Delivery_status: @message_detail.status}

  class ComplaintMessage extends Message
    constructor: (message) ->
      @message_detail = message.details.complaint_details
      @unique_fields = {Complaint_type: @message_detail.complaint_type, Complaint_date: @message_detail.complaint_date}

  class StatMessage
    constructor: (message) ->
      @bounced = message.bounced
      @delivery = message.delivered
      @complaints = message.complaint
      @fields = {Bounces: message.bounced, Deliveries: message.delivered, Complaints: message.complaint}

    format_title: ->
      ''
    format: ->
      "*Bounces* #{@bounced}\n*Deliveries* #{@delivery}\n*Complaints* #{@complaints}\n"

    format_for_attachment: ->
      formatted_fields = []
      for key,value of @fields
        formatted_fields.push({
          "title": "#{key}",
          "value": "#{value}",
          "short": true
        })
      return formatted_fields
