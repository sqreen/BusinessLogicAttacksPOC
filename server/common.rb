
require 'yaml'

CONFIG = 'config.yml'


def parse_config(filename)
    # Populate configuration

    YAML.load File.read(filename)

end

# Store temporal data for a given element to be monitored.
# Allows to check if it goes over threshold in a certain period of time.
class Alerter
    

    attr_reader :values

    def initialize(threshold, duration)
        @threshold = threshold
        @duration = (duration / 60 == 0 ? 1 : duration / 60)
        # Hash time -> count
        @values = Hash.new { |k, v| k[v] = 0 }
    end

    def append(time)

        minute = time / 60

        @values[minute] += 1

    end

    def check_threshold_now

        max = Time.now.to_i / 60
        check_threshold(@threshold, @duration, max) or
            check_threshold(@threshold, @duration, max - 1)
    end

    def check_threshold(threshold, duration, max)

        sum = 0
        @values.each do |k, m|
            if k < max - duration
                # too old
                @values.delete(k)
            else
                sum += m
                break if sum >= threshold
            end
        end
        sum >= threshold
    end
end


class EventDataStore

    def initialize(threshold, duration)
        @threshold = threshold
        @duration = duration
        @data = Hash.new { |h, k| h[k] = Alerter.new(@threshold, @duration) }
    end

    def append(key, time)
        alerter = @data[key]
        alerter.append(time)
        alerter.check_threshold_now
    end

end

class EventsStore
    def initialize(alerts)
        @events = {}
        alerts.each do |event_name, config|
            @events[event_name] = EventDataStore.new(config["threshold"], config["duration"])
        end
    end

    def append(event_name, key, time)
        ev = @events[event_name]
        if ev.nil?
            raise "unknown event name '#{event_name}'"
        else
            @events[event_name].append(key, time)
        end
    end
end

