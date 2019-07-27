require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

require_relative 'lib/monday_client'
require_relative 'lib/slack_api_client'

get '/' do
  return { hello: 'monday unfurly!' }.to_json
end

post '/' do
  p '[START]'
  params = JSON.parse(request.body.read)

  case params['type']
  when 'url_verification'
    challenge = params['challenge']
    return {
        challenge: challenge
    }.to_json

  when 'event_callback'
    channel = params.dig('event', 'channel')
    ts = params.dig('event', 'message_ts')
    links = params.dig('event', 'links')

    unfurls = links.each_with_object({}) do |link, memo|
      url = link['url']
      attachment = MondayClient.fetch(url)
      memo[url] = attachment
    end

    payload = {
        channel: channel,
        ts: ts,
        unfurls: unfurls
    }.to_json
    p "[LOG] payload=#{payload}"

    SlackApiClient.post(payload)
  else
    p "[LOG] other type. params: #{params}"
  end

  p '[END]'
  return {}.to_json
end
