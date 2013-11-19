require "rubygems"
require "bunny"

@conn = Bunny.new ENV['AMQP_URL']
@conn.start
