# Description
#   Interact with the Unfuddle API.
#
# Dependencies:
#   "unfuddle-api": "~0.0.1"
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

Unfuddle = require '../custom_deps/unfuddle-api'

module.exports = (robot) ->
  host     = process.env.HUBOT_UNFUDDLE_SUBDOMAIN
  user     = process.env.HUBOT_UNFUDDLE_USER
  password = process.env.HUBOT_UNFUDDLE_PASSWORD

  unf = new Unfuddle(host, user, password)

  robot.hear /(\w+) #(\d*)/i, (msg) ->
    project_id = msg.match[1]
    ticket_num = msg.match[2]

    unf.ticket project_id, ticket_num, (ticket) ->
      if ticket
        msg.send ticket.number + ": " + ticket.summary
        msg.send unf.ticketUrl ticket
      else
        msg.send "I can't seem to find that ticket."


  robot.hear /tired|too hard|to hard|upset|bored|bothered/i, (msg) ->
    msg.send "Panzy"
