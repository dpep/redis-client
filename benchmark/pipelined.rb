# frozen_string_literal: true

require_relative "setup"

redis_client = RedisClient.new(host: "localhost", port: RedisServerHelper::REAL_TCP_PORT)
redis = Redis.new(host: "localhost", port: RedisServerHelper::REAL_TCP_PORT, driver: :ruby)
hiredis = Redis.new(host: "localhost", port: RedisServerHelper::REAL_TCP_PORT, driver: :hiredis)

redis_client.call("SET", "key", "value")
redis_client.call("SET", "large", "value" * 10_000)
redis_client.call("LPUSH", "list", *5.times.to_a)
redis_client.call("LPUSH", "large-list", *1000.times.to_a)
redis_client.call("HMSET", "hash", *8.times.to_a)
redis_client.call("HMSET", "large-hash", *1000.times.to_a)

benchmark("small string") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.get("key") } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.get("key") } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("GET", "key") } } }
end

benchmark("large string") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.get("large") } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.get("large") } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("GET", "large") } } }
end

benchmark("small list") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.lrange("list", 0, -1) } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.lrange("list", 0, -1) } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("LRANGE", "list", 0, -1) } } }
end

benchmark("large list") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.lrange("large-list", 0, -1) } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.lrange("large-list", 0, -1) } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("LRANGE", "large-list", 0, -1) } } }
end

benchmark("small hash") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.hgetall("hash") } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.hgetall("hash") } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("HGETALL", "hash") } } }
end

benchmark("large hash") do |x|
  x.report("redis-rb") { redis.pipelined { |p| 100.times { p.hgetall("large-hash") } } }
  x.report("hiredis-rb") { hiredis.pipelined { |p| 100.times { p.hgetall("large-hash") } } }
  x.report("redis-client") { redis_client.pipelined { |p| 100.times { p.call("HGETALL", "large-hash") } } }
end