#!/usr/bin/env ruby
# encoding: utf-8

require "./connect.rb"
require "json"
require "kramdown"
require "rest_client"

ch = @conn.create_channel
ch.prefetch 1

q  = ch.queue("documents.ready", :no_declare => true)

author = `whoami`

q.subscribe(:block => true, :ack => true) do |delivery_info, metadata, payload|
  data = JSON.parse(payload)
  destination = data["destination"]
  html = Kramdown::Document.new(data["markdown"]).to_html
  result = RestClient.post destination, html, :author => author
  puts "Message delivered to #{destination}: #{result}"
  ch.ack(delivery_info.delivery_tag)
end
