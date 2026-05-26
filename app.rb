require 'sinatra'
require 'redis'

redis = Redis.new(host: 'localhost', port: 6379)

post '/enqueue/:item' do
  item_value = params[:item]

  unless item_value =~ /\A\d+\z/
    status 400
    return { message: 'Item must be numeric' }.to_json
  end

  redis.lpush('items', item_value)
  status 200
  { message: "Enqueued item #{item_value} to redis queue" }.to_json
end
