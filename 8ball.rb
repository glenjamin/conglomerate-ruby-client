#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "json"
require "bunny"

conn = Bunny.new ENV['AMQP_URL']
conn.start

ch = conn.create_channel
x  = ch.topic("8ball", :no_declare => true)

question = if ARGV.length > 0
  ARGV.join(" ")
else
  raise "missing message"
end

question2 = [
  "Should robots be free?",
  "Can a computer ever generate a truly random number?",
  "Is iRobot a good film?",
  "Is the NSA listening?"
].sample

ch = conn.create_channel
q  = ch.queue("", :auto_delete => true, :exclusive => true)
q.bind(x, :routing_key => q.name);

puts "Your question: #{question}"
puts "My question: #{question2}"

x.publish(
  question,
  :routing_key => '8ball',
  :reply_to => q.name,
  :correlation_id => 1
)

x.publish(
  question2,
  :routing_key => '8ball',
  :reply_to => q.name,
  :correlation_id => 2
)

answers = {}

consumer = q.subscribe do |delivery_info, metadata, payload|
  id = metadata.correlation_id.to_i
  answers[id] = payload
  puts "Response #{id} arrived"
  consumer.cancel if answers.length == 2
end

ch.work_pool.join

puts "Your response: #{answers[1]}"
puts "My response: #{answers[2]}"