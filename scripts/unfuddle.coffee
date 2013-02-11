# Description
#   Interact with the Unfuddle API.
#
# Dependencies:
#   "unfuddle": "~0.0.1"
#   "rsvp": "~1.2.0"
#   "restify": "~2.1.1"
#
# Configuration:
#   HUBOT_UNFUDDLE_SUBDOMAIN
#   HUBOT_UNFUDDLE_USER
#   HUBOT_UNFUDDLE_PASSWORD
#
# Commands:
#   hubot <trigger> - <what the respond trigger does>
#   (proj_id|proj_short_name) #(ticket_num) - Responds with ticket no., short description and url.
#
# Notes:
#   None
#
# Author:
#   tnightingale

Unfuddle = require '../custom_deps/unfuddle'

module.exports = (robot) ->
  host     = process.env.HUBOT_UNFUDDLE_SUBDOMAIN
  user     = process.env.HUBOT_UNFUDDLE_USER
  password = process.env.HUBOT_UNFUDDLE_PASSWORD

  unf = new Unfuddle(host, user, password)

  respond = (msg) ->
    project_id = msg.match[1]
    ticket_num = msg.match[2]

    success = (ticket) ->
      msg.send ticket.number + ": " + ticket.summary
      msg.send unf.ticketUrl ticket

    error = (err) ->
      msg.send "I can't seem to find that ticket."

    unf.ticket(project_id, ticket_num).then success, error

  respond_multiple = (msg) ->
    msg.match.forEach (m) ->
      msg.match = m.match(new RegExp(match_urls.source, 'i'))
      respond msg

  # This isn't pretty.
  match_urls = new RegExp("https://" + host + ".unfuddle.com(?:/a#)?/projects/(\\d+)/tickets/by_number/(\\d+)", "ig")

  robot.hear /(\w+) #(\d*)/i, respond
  robot.hear match_urls, respond_multiple

  robot.respond /unfuddle project (\w+)/, (msg) ->
    msg.send msg.room

  robot.hear /tired|too hard|to hard|upset|bored|bothered/i, (msg) ->
    msg.send "Panzy"
