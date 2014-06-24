# Description:
#   OMG Animals
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   omg - Get an OMG animal

module.exports = (robot) ->

  robot.hear /omg/i, (msg) ->
    msg.http("http://pure-brook-7702.herokuapp.com")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).omg
