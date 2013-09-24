#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "bunny"

conn = Bunny.new ENV['AMQP_URL']
conn.start

ch = conn.create_channel
ex = ch.topic("logs", :no_declare => true)
q  = ch.queue("", :auto_delete => true, :exclusive => true)
key = ARGV[0] || "#"
q.bind(ex, :routing_key => key)

STDERR.puts "Bound to #{key}"

q.subscribe(:block => true, :ack => false) do |delivery_info, metadata, payload|
  STDOUT.write payload + "\n"
  STDOUT.flush
end