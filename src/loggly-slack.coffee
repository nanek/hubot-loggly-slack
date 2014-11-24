# Description:
#   Announce Loggly notifications to a slack room.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Notes:
#   To use:
#     Setup http://hostname/hubot/loggly-slack/%23ROOMNAME as
#     your Alert Endpoint in loggly.com. Use GET as the method.
#     The POST method will post as text/plain and not be parsed properly.
#

bodyParser = require 'body-parser'

module.exports = (robot) ->

  middleware = bodyParser.json type: 'text/plain'

  robot.router.post '/hubot/loggly-slack/:room', middleware, (req, res) ->
    room = req.params.room

    data = req.body

    # Example post data
    #
    # {
    #   "alert_name": "Name of Alert",
    #   "edit_alert_link": "https://company.loggly.com/alerts/edit/99999",
    #   "source_group": "Source Group",
    #   "start_time": "Aug 29 01:35:52",
    #   "end_time": "Aug 29 01:40:52",
    #   "search_link": "https://company.loggly.com/search/?terms=json.level%3Aerror",
    #   "query": "json.level:error",
    #   "num_hits": 10,
    #   "recent_hits": [],
    #   "owner_username": "company",
    #   "owner_subdomain": "company",
    #   "owner_email": "company@example.com"
    # }

    fields = [
        title: data.alert_name
        value: data.search_link
        short: true
      ,
        title: "Time"
        value: "#{data.start_time} to #{data.end_time}"
        short: true
      ,
        title: "Hits #{data.num_hits}"
        value: data.query
        short: false
    ]

    fallback = "#{data.alert_name} : #{data.search_link}"

    robot.emit 'slack-attachment',
      message:
        room:       room
        username:   'loggly'
        icon_emoji: ":warning:"
      content:
        text:     ''
        color:    "danger"
        pretext:  ''
        fallback: fallback
        fields:   fields

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
