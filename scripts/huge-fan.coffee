# Description:
#   Huge fan
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   a fan - Show some passion

fans = [
  'http://www.ofthefittestcomic.com/comics/2011-08-30-huge-fan.jpg',
  'http://static1.fjcdn.com/comments/Huge+metal+fan+here+_959cb127ae4cdb60f5d508b96cb01bb0.jpg',
  'http://files.doobybrain.com/wp-content/uploads/2012/08/Tal-Tenne-Czaczkes-giant-fan.jpg',
  'http://images.sodahead.com/polls/001092831/Big_Fan_xlarge.jpeg',
  'http://cdn.shopify.com/s/files/1/0301/0501/products/I_m-a-HUGE-Metal-Fan.jpg',
  'https://s-media-cache-ak0.pinimg.com/736x/e6/9d/01/e69d015796f19e02e8e021a5f3a07c09.jpg'
]

module.exports = (robot) ->
  robot.hear /a (huge )?(big )?fan/i, (msg) ->
      msg.send fans[Math.floor(Math.random() * fans.length)];

