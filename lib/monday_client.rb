require "net/http"
require "uri"
require 'json'

class MondayClient
  MONDAY_API_V2_TOKEN = ENV['MONDAY_API_V2_TOKEN']
  MONDAY_API_ENDPOINT = "https://api.monday.com/v2/".freeze

  class << self
    def fetch(url)
      item = fetch_monday_item(url)
      return {} if item.nil?

      format_response(url, item)
    end

    private

    def fetch_monday_item(url)
      res = http_client.request(http_request(query(url)))
      return unless res.code == '200'

      items_data = JSON.parse(res.body)
      items_data.dig('data', 'items').first
    end

    def item_num(url)
      return unless (match_data = %r(\Ahttps://.+.monday.com/boards/(\d+)/pulses/(?<item_num>\d+).*\z).match(url))

      match_data[:item_num]
    end

    def query(url)
      %Q({"query":"{ items(ids: [#{item_num(url)}]) { name group { title } creator { name photo_thumb } board { name } } }"})
    end

    def uri
      URI.parse(MONDAY_API_ENDPOINT)
    end

    def http_request(body)
      Net::HTTP::Post.new(uri.request_uri).tap do |req|
        req['Content-Type'] = 'application/json; charset=utf-8'
        req["Authorization"] = MONDAY_API_V2_TOKEN
        req['API-Version'] = '2024-01'
        req.body = body
      end
    end

    def http_client
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = true
      end
    end

    def format_response(url, item)
      footer = "Board: #{item['board']['name']}, Group: #{item['group']['title']}, Created By: #{item['creator']['name']}"
      {
          title: item['name'],
          title_link: url,
          color: '#FF3D56',
          footer: footer
      }

    end
  end
end
