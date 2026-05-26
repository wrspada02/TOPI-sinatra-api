require 'sinatra'
require 'redis'
require 'json'

redis = Redis.new(host: '', port: 6379)

post '/enqueue/:item' do
    item_value = params[:item]

    redis.lpush('items', item)
    status 200
    { message: 'Enqueued item #{item_value} to redis queue' }.to_json 
end
