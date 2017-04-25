require 'twilio-ruby'
require 'sinatra'
require 'sinatra/json'
require 'dotenv'
require 'faker'
require "pry"
# Load environment configuration
Dotenv.load

# Render home page
get '/' do
  File.read(File.join('public', 'index.html'))
end

# Generate a token for use in our Video application
get '/token' do
  # Create a random username for the client
  identity = Faker::Internet.user_name.gsub(/[^0-9a-z_]/i, '')
  account_sid = 'AC8bbfecb0eb3c600d9b7ed962f14afe5d'
  auth_token = 'ec4a7b05749b11e2882f3b678c86dc72'
  app_sid = 'AP3853d90ad697a5be74043d8b8a80dc4a'
  capability = Twilio::Util::Capability.new account_sid, auth_token
  # Create an application sid at
  # twilio.com/console/phone-numbers/dev-tools/twiml-apps and use it here
  capability.allow_client_outgoing app_sid
  capability.allow_client_incoming identity
  token = capability.generate

  # Generate the token and send to client
  json :identity => identity, :token => token
end
caller_id = "+18775546973"
post '/voice' do
  twiml = Twilio::TwiML::Response.new do |r|
    if params['To'] and params['To'] != ''
      r.Dial callerId: caller_id do |d|
        # wrap the phone number or client name in the appropriate TwiML verb
        # by checking if the number given has only digits and format symbols
        if params['To'] =~ /^[\d\+\-\(\) ]+$/
          d.Number params['To']
        else
          d.Client params['To']
        end
      end
    else
      r.Say "Thanks for calling!"
    end
  end
  content_type 'text/xml'
  twiml.text
end
