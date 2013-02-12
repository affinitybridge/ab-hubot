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

Util = require "util"
Unfuddle = require '../custom_deps/unfuddle'

module.exports = (robot) ->
  subdomain = process.env.HUBOT_UNFUDDLE_SUBDOMAIN
  user     = process.env.HUBOT_UNFUDDLE_USER
  password = process.env.HUBOT_UNFUDDLE_PASSWORD

  robot.brain.data.unfuddle = robot.brain.data.unfuddle or projects: {}
  projects = robot.brain.data.unfuddle.projects

  unf = new Unfuddle(subdomain, user, password)

  # Returns a string of ticket information.
  ticket_info = (ticket) ->
    "##{ticket.number}, #{ticket.summary} " +
    "(http://#{subdomain}.unfuddle.com/projects/#{ticket.project_id}/by_number/#{ticket.number})"

  # Match Unfuddle ticket urls.
  match_urls = new RegExp("https://#{subdomain}.unfuddle.com(?:/a#)?/projects/(\\d+)/tickets/by_number/(\\d+)", "ig")

  # Ticket information listener.
  #
  # Pulls a project id and a ticket number from a response match and makes an
  # API request.
  request_ticket_info = (response) ->
    project_id = response.match[1]
    ticket_num = response.match[2]
    success = (ticket) -> response.send ticket_info ticket
    error = (err) -> response.send "I can't seem to find that ticket."
    unf.ticket(project_id, ticket_num).then success, error

  # 
  # <project.short_name> #<ticket.number>
  #
  robot.hear /^(\w+) #(\d+)$/, request_ticket_info

  #
  # <unfuddle ticket url(s)>
  #
  robot.hear match_urls, (response) ->
    response.match.forEach (m) ->
      response.match = m.match(new RegExp(match_urls.source, 'i'))
      request_ticket_info response

  #
  # #<ticket.number>
  #
  robot.hear /#(\d+)/gi, (response) ->
    room = response.envelope.room

    success = (ticket) -> response.send ticket_info ticket
    error = (err) -> response.send "I can't find that ticket."
    get_ticket = (project, num) -> unf.ticket(project.id, +num).then success, error

    if not projects[room]
      response.send "There is no project associated with this room. Please specify a project."
    else
      get_ticket projects[room], num.substr(1) for num in response.match

  #
  # @hubot use the <project.short_name> unfuddle project>
  #
  robot.respond /use the (\w+) unfuddle project$/, (response) ->
    room = response.envelope.room

    success = (project) ->
      projects[room] = project
      response.send "I have associated the #{project.short_name} (#{project.id}) project with this room."
    error = (err) ->
      response.send "I can't do that."
    unf.projectByShortName(response.match[1]).then success, error

  #
  # ...
  #
  robot.hear /tired|too hard|to hard|upset|bored|bothered/i, (response) ->
    response.send "Panzy"
