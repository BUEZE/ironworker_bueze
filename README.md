# Example of IronWorker that uses gems

## Setup

1. Create a new project on Ironworker, and a new worker within it
  - Create a new project/worker for this project
  - notice a link on the 'Getting Started' page for your worker's `iron.json`
2. Create the base for this project
  - Git clone this project onto your local machine
  - Download your `iron.json` file from your worker on iron.io to this repo
3. Note that the Gemfile specifies you should use Ruby 2.1.0, so install it
  - `$ rvm install 2.1.0`

## Configure and test the worker locally

1. Configure this project
  - Create a `/config/config.json` file
  - Copy and modify contents of `config/example_config.json` to `config/config.json`
2. Test this worker
  - `$ bundle install --standalone`
    - creates a bundle of all needed gems within your repo
  - `$ ruby soa_worker.rb`
    - expects you to have an 'SOA_queue' on your regional SQS with JSON messages like:
      - `{ url: 'http://cadetdynamo.herokuapp.com/api/v3/cadet/soumya.ray.json' }`
      - `{ url: 'http://cadetdynamo.herokuapp.com/api/v3/cadet/chenlizhan.json' }`

## Deploy and run this worker

3. Upload your worker
  - `$ zip -r soa_worker.zip .`
    - creates a zip of all files in this folder
  - `$ iron worker upload --zip soa_worker.zip --name soa_worker iron/images:ruby-2.1 ruby soa_worker.rb`
    - creates a zip of your entire repo
4. Run your worker remotely
  - `$ iron worker queue --wait soa_worker`
    - runs your worker on iron.io
