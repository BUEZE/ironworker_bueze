require_relative 'bundle/bundler/setup'
require 'json'
require 'aws-sdk'
require 'httparty'

# Worker code can be anything you want.
puts "Starting HelloWorker at #{Time.now}"
puts "Setting up AWS connection"

config = JSON.parse(File.read('config/config.json'))
ENV.update config
sqs = Aws::SQS::Client.new
q_url = sqs.get_queue_url(queue_name: 'SOA_queue').queue_url

puts "Polling SQS for messages"

poller = Aws::SQS::QueuePoller.new(q_url)

begin
  poller.poll(wait_time_seconds:nil, idle_timeout:5) do |msg|
    puts "MESSAGE: #{JSON.parse(msg.body)}"
    req = JSON.parse msg.body
    results = HTTParty.get req['get']
    puts "RESULTS: #{results}\n\n"
  end
rescue Aws::SQS::Errors::ServiceError => e
  # rescues all errors returned by Amazon Simple Queue Service
  puts "ERROR FROM SQS: #{e}"
end

puts "HelloWorker completed at #{Time.now}"

# bundle install --standalone
# zip -r hello_worker.zip .
# iron worker upload --zip hello_worker.zip --name hello_worker iron/images:ruby-2.1 ruby hello_worker.rb
#
# iron worker queue --wait hello_worker
