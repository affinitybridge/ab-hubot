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
#   nods - shows an encouraging nod
#
# Author:
#   thomasallanlamb

module.exports = (robot) ->
  robot.hear /(^|\W)nods(?! off)(\z|\W|$)/i, (msg) ->
    msg.send "http://i.imgur.com/EucIfYY.gif"