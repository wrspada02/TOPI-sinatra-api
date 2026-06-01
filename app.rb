require 'sinatra'
require 'redis'
require 'json'
require 'socket'

set :bind, '0.0.0.0'
set :port, ENV.fetch('PORT', 4567)

def log(msg)
  puts "[API #{Socket.gethostname}] #{msg}"
end

def redis
  @redis ||= begin
    log "Connecting to Redis at #{ENV.fetch('REDIS_HOST', 'redis')}:#{ENV.fetch('REDIS_PORT', '6379')}"
    Redis.new(
      host: ENV.fetch('REDIS_HOST', 'redis'),
      port: ENV.fetch('REDIS_PORT', '6379').to_i
    )
  end
end

before do
  content_type :json
end

# Optional health check (VERY useful in Swarm)
get '/health' do
  begin
    redis.ping
    log "Health check OK"
    status 200
    { status: "ok" }.to_json
  rescue => e
    log "Health check FAILED: #{e.class} #{e.message}"
    status 503
    { status: "redis_unavailable" }.to_json
  end
end

post '/enqueue/:item' do
  item_value = params[:item]

  log "Received enqueue request item=#{item_value}"

  unless item_value =~ /\A\d+\z/
    log "Validation failed item=#{item_value}"
    status 400
    return { message: 'Item must be numeric' }.to_json
  end

  begin
    redis.ping
    redis.lpush('items', item_value)

    log "Enqueued item=#{item_value} queue=items"

    status 200
    { message: "Enqueued item #{item_value} to redis queue" }.to_json

  rescue Redis::BaseError => e
    log "Redis error on enqueue: #{e.class} #{e.message}"

    status 503
    { message: "Redis unavailable" }.to_json
  end
end
