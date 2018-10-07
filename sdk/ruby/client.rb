
require "net/http"
require "uri"
require "json"

class BusinessLogic

    def initialize(url)
        @uri = URI.parse(url)
        @http = Net::HTTP.new(@uri.host, @uri.port)
    end

    def track(event_name, ip)
        post = Net::HTTP::Post.new(@uri.request_uri)
        post.body = JSON::dump({ "event_name" => event_name, "ip" => ip, "time" => Time.now.to_s })
        @http.request(post)
    end
end


if __FILE__ == $0 then

    if ARGV.size != 1 then
        $stderr.puts "Usage: #{$0} URI"
        exit(1)
    end
    bl = BusinessLogic.new(ARGV[0])
    bl.track("reset_password", "2.3.4.5")
end
