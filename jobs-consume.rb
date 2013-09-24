#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "json"
require "bunny"
require "kramdown"
require "rest_client"

conn = Bunny.new ENV['AMQP_URL']
conn.start

ch = conn.create_channel
q  = ch.queue("documents.ready", :no_declare => true)

q.subscribe(:block => true, :ack => true) do |delivery_info, metadata, payload|
  data = JSON.parse(payload)
  destination = data["destination"]
  html = Kramdown::Document.new(data["markdown"]).to_html
  result = RestClient.post destination, html
  puts "Message delivered to #{destination}: #{result}"
  ch.ack(delivery_info.delivery_tag)
end