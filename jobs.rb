#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "json"
require "bunny"

conn = Bunny.new ENV['AMQP_URL']
conn.start

ch = conn.create_channel
ch.prefetch 1
q  = ch.queue("documents.ready", :no_declare => true)

q.subscribe(:block => true, :ack => true) do |delivery_info, metadata, payload|
  data = JSON.parse(payload)
  destination = data["destination"]
  puts "Would post back to #{destination}"
  ch.ack(delivery_info.delivery_tag)
end