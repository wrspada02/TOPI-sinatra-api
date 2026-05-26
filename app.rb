require 'sinatra'
require 'redis'

redis = Redis.new(host: '', port: 6379)

post '/enqueue/:item' do
    item_value = params[:item]

    if (!item_value.is_a?(Numeric)) {
        status 400
        { message: 'Item must be numeric' }.to_json
    }

    redis.lpush('items', item)
    status 200
    { message: 'Enqueued item #{item_value} to redis queue' }.to_json
end
