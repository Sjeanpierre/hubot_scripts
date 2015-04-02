access_key = process.env.RFC_ACCESS_KEY
secret_key = process.env.RFC_SECRET_KEY
basic_user = process.env.RFC_BASIC_USER
basic_pass = process.env.RFC_BASIC_PASS
rcf_url = process.env.RFC_URL
auth = 'Basic ' + new Buffer(basic_user + ':' + basic_pass).toString('base64');
rfc_url = "https://#{basic_user}:#{basic_pass}@#{rfc_url}/api/changes"

module.exports = (robot) ->
  robot.hear /rfcs/i, (msg) ->
    msg.http("#{rfc_url}/list.json")
    .headers("Access-Key": access_key, "Secret-Key": secret_key, Accept: 'application/json')
    .get() (err, res, body) ->
      data = JSON.parse(body)
      for rfc in data
        change = new Rfc(rfc)
        robot.emit 'slack.attachment',
          message: msg.message
          content:
            text: change.format_title()
            fallback: change.format()
            color: change.display_color()
            fields: change.format_for_attachment()

  robot.hear /RFC\#?\s?(\d*)/i, (msg) ->
    rfc_id = escape(msg.match[1])
    console.log(msg)
    msg.http("#{rfc_url}/#{rfc_id}")
    .headers("Access-Key": access_key, "Secret-Key": secret_key, Accept: 'application/json')
    .get() (err, res, body) ->
      rfc = JSON.parse(body)
      change = new Rfc(rfc)
      robot.emit 'slack.attachment',
        message: msg.message
        content:
          text: change.format_title()
          fallback: change.format()
          color: change.display_color()
          fields: change.format_for_attachment()

  robot.hear /https:\/\/rfc\.na\.sageonestaging\.com\/change\/(\d+)/, (msg) ->
    rfc_id = escape(msg.match[1])
    console.log(msg)
    msg.http("#{rfc_url}/#{rfc_id}")
    .headers("Access-Key": access_key, "Secret-Key": secret_key, Accept: 'application/json')
    .get() (err, res, body) ->
      rfc = JSON.parse(body)
      change = new Rfc(rfc)
      robot.emit 'slack.attachment',
        message: msg.message
        content:
          text: change.format_title()
          fallback: change.format()
          color: change.display_color()
          fields: change.format_for_attachment()

  class Rfc
    constructor: (change_object) ->
      @id = change_object.id
      @creator = change_object.created_by
      @created_date = change_object.created_date
      @region = change_object.product.country
      @product = change_object.product.name
      #      @due_date = Date.parse(change_object.due_date)
      @title = change_object.title
      @ctype = change_object.type
      @impact = change_object.impact
      @priority = change_object.priority
      @status = change_object.status
      @system = "#{change_object.system.category}-#{change_object.system.name}"

    format_for_attachment: ->
      formatted_fields = []
      fields = {Creator: @creator, 'Created at': @created_date, Region: @region, Product: @product, 'Change type': @ctype, Priority: @priority, Status: @status, System: @system}
      for key,value of fields
        formatted_fields.push({
          "title": "#{key}",
          "value": "#{value}",
          "short": true
        })
      return formatted_fields

    display_color: ->
      color = switch "#{@priority}"
        when 'high' then '#F35A00'
        when 'medium' then '#FCDC3B'
        when 'low' then '#AADD00'
      return color

    format_title: ->
      "<https://rfc.na.sageonestaging.com/change/#{@id}|RFC##{@id}> - #{@title}"

    format: ->
      "*ID:* #{@id}\n*Created by:* #{@creator}\n*Created At:* #{@created_date}\n*Region:* #{@region}\n*Product:* #{@product}\n*Change Type:* #{@ctype}\n*Impact:* #{@impact}\n*Priority:* #{@priority}\n*Status:* #{@status}\n*System:* #{@system}\n*Title:* #{@title}\n-----------------------" #Date Due: #{@due_date}"
