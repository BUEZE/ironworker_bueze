require_relative 'bundle/bundler/setup'
require 'json'
require 'aws-sdk'
require 'httparty'

puts "Starting SOA_worker at #{Time.now}"

puts "Setting up AWS connection"
config = JSON.parse(File.read('config/config.json'))
ENV.update config
sqs = Aws::SQS::Client.new
msg = {url: 'http://bueze.herokuapp.com/api/v1/bookranking/', body: '{"source":"bueze"}'}
q_url = sqs.get_queue_url(queue_name: 'SOA_queue').queue_url
msg_sent = sqs.send_message(queue_url: q_url, message_body: msg.to_json)

puts "Polling SQS for messages"
poller = Aws::SQS::QueuePoller.new(q_url)
begin
  poller.poll(wait_time_seconds:nil, idle_timeout:5) do |msg|
    puts "MESSAGE: #{JSON.parse(msg.body)}"
    req = JSON.parse msg.body
    # results = HTTParty.get req['url']
    results = HTTParty.post(req['url'],
      {body: "#{msg['body']}"}
    )
    puts "RESULTS: #{results}\n\n"
  end
rescue Aws::SQS::Errors::ServiceError => e
  puts "ERROR FROM SQS: #{e}"
end

puts "SOA_worker completed at #{Time.now}"
