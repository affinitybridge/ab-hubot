# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   magic - Shows a picture of Shia Labeo doing Magic
#
# Author:
#   altrugon

module.exports = (robot) ->
  robot.hear /(^|\W)magic(\z|\W|$)/i, (msg) ->
    msg.send "http://i.imgur.com/96t6I9m.gif"