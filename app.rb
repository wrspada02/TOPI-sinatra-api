require 'sinatra'
require 'redis'
require 'json'

def redis
  @redis ||= Redis.new(
    host: ENV.fetch('REDIS_HOST', 'redis'),
    port: ENV.fetch('REDIS_PORT', '6379').to_i
  )
end

before do
  content_type :json
end

post '/enqueue/:item' do
  item_value = params[:item]

  unless item_value =~ /\A\d+\z/
    status 400
    return { message: 'Item must be numeric' }.to_json
  end

  begin
    redis.ping
    redis.lpush('items', item_value)

    status 200
    { message: "Enqueued item #{item_value} to redis queue" }.to_json

  rescue Redis::BaseError => e
    status 503
    { message: "Redis unavailable: #{e.message}" }.to_json
  end
end
