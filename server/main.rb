require 'http'
require 'sinatra'

require 'time'

require_relative 'common'


config = parse_config(CONFIG)
$queue = Queue.new
$es = EventsStore.new(config["alerts"])

Thread.new do

    while true do
        message = $queue.pop

        puts "found #{message.inspect}, about to perform webhook"
        begin
            HTTP.post(config['webhook'], :json => JSON::dump(message))
        rescue Exception => e
            $stderr.puts e.inspect
        end
    end
end


class EventServer < Sinatra::Base

    config = parse_config(CONFIG)

    configure do
        enable :logging
    end

    post "/event" do

        request.body.rewind  # in case someone already read it
        begin
            body = request.body.read
            logger.info body
            message = JSON.parse body
        rescue JSON::ParserError
            logger.error "Cannot parse JSON #{body.inspect}"
            halt
        end

        time = Time.parse(message["time"]).to_i
        if time.nil?
            logger.error "Cannot parse time #{message["time"]}"
            halt
        end
        begin
            alert = $es.append(message["event_name"], message["ip"], time)
        rescue Exception => e
            logger.error(e.inspect)
        end
        if alert
            logger.info "Sending message #{message.inspect}"
            $queue.push(message)
        end

        nil
    end

    post "/alert_triggered/" do
        request.body.rewind  # in case someone already read it
        body = request.body.read
        begin
            message = JSON.parse body
        rescue Exception => e
            logger.error "Couldn't parse message #{body}"
            halt
        end
        logger.warn "An alert was received: #{message}"
    end

    run!
end

