#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "json"
require "bunny"

conn = Bunny.new ENV['AMQP_URL']
conn.start

ch = conn.create_channel
x  = ch.topic("chat", :no_declare => true)

room = ARGV.shift or raise "missing room"
name = ARGV.shift or raise "missing name"

msg  = if ARGV.length > 0 then ARGV.join(" ") else raise "missing message" end

puts "Messaging #{room} from #{name}: #{msg}"

x.publish(
  {"name" => name, "message" => msg}.to_json,
  :routing_key => room,
  :content_type => 'application/json'
)