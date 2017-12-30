require 'sinatra'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'yaml'


get '/' do
  erb :index
end

post '/report' do
  date = params[:date].split() if params[:date]
  config = YAML.load_file("config.yml")
  min_date = date[0] 
  max_date = date[2]

  content_type :json
  url = "https://monksprint.myshopify.com/admin/orders.json?created_at_min="+min_date +"&created_at_max="+max_date
  uri = URI(url)
  puts uri

  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https',
    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth config['access_key'], config['password']

    response = http.request request # Net::HTTPResponse object

    response = response.body
    response = JSON.parse(response)
    puts response["orders"]
    unless response["orders"] =0
       total = 0
       response["orders"].each do |res|
          total += res["total_price"].to_i
       end
       p total
      return { "total": total, "profit":  total * 0.20 }.to_json
   else
      return { "Result": "Results not found for the date range selected" }.to_json
   end
  end
end
