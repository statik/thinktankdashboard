# encoding: UTF-8

require 'google/api_client'
require 'date'
require 'time'
require 'digest/md5'
require 'active_support'
require 'active_support/all'
require 'json'
require 'pry'
require 'pp'

# Update these to match your own apps credentials
service_account_email = ENV['GOOGLE_SERVICE_ACCOUNT_EMAIL'] # Email of service account
key_file = nil # File containing your private key
key_secret = ENV['GOOGLE_SERVICE_KEY_SECRET'] # Password to unlock private key
calendarID = ENV['ATTENDEE_CALENDAR_ID'] # Calendar ID.

# Get the Google API client
client = Google::APIClient.new(:application_name => 'Dashing Calendar Widget',
  :application_version => '0.0.1')

# Load your credentials for the service account
if not key_file.nil? and File.exists? key_file
  key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
else
  key = OpenSSL::PKey::RSA.new ENV['GOOGLE_SERVICE_PK'], key_secret
end

client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/calendar.readonly',
  :issuer => service_account_email,
  :signing_key => key)

#binding.pry
# Start the scheduler
#SCHEDULER.every '15m', :first_in => 4 do |job|

  # Request a token for our service account
client.authorization.fetch_access_token!

  # Get the calendar API
service = client.discovered_api('calendar','v3')

  # Start and end dates
now = DateTime.now

result = client.execute(:api_method => service.events.list,
                          :parameters => {'calendarId' => calendarID,
                                          'timeMin' => now.rfc3339,
                                          'orderBy' => 'startTime',
                                          'singleEvents' => 'true',
                                          'maxResults' => 6})  # How many calendar items to get

PP.pp result.data
#  send_event('google_calendar', { events: result.data })

#end
