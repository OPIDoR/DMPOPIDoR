require 'httparty'

namespace :probe do
  desc "Liveness check by querying /healthz"
  task :liveness => :environment do
    begin
      url = "http://localhost:3000/healthz"

      response = HTTParty.get(url)
      if response.code == 200 && response.parsed_response['status'] == 'Healthy'
        puts "✅ Liveness check passed: #{response.body}"
        exit 0
      else
        puts "❌ Liveness check failed: expected {\"status\":\"Healthy\"}, got #{response.body}"
        exit 1
      end
    rescue => e
      puts "❌ Liveness check error: #{e.message}"
      exit 1
    end
  end

  task :readiness => :environment do
    begin
      redis_url = Rails.configuration.x.dmpopidor.redis_url
      redis = Redis.new(url: redis_url)

      pong = redis.ping
      if pong == "PONG"
        puts "✅ Redis connection OK"
      else
        puts "❌ Redis ping failed"
        exit 1
      end
    rescue => e
      puts "❌ Redis connection failed: #{e.message}"
    end

    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✅ Postgres connection OK"
    rescue => e
      puts "❌ Postgres connection failed: #{e.message}"
      exit 1
    end
  end
end
