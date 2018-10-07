
require "minitest/autorun"

require_relative 'common.rb'

class TestAlerter < Minitest::Test

    def test_alerts

        a = Alerter.new(2, 300)

        a.append(Time.now.to_i)
        assert_equal a.check_threshold_now, false

        a.append(Time.now.to_i)
        assert a.check_threshold_now


        a = Alerter.new(2, 300)
        a.append(Time.now.to_i)
        assert_equal a.check_threshold_now, false

        a.append(Time.now.to_i - 301)
        assert a.check_threshold_now

        a = Alerter.new(2, 300)
        a.append(Time.now.to_i)
        a.append(Time.now.to_i - 361)
        assert_equal a.check_threshold_now, false

    end

    def test_event_datastore

        now = Time.now.to_i
        threshold = 2
        duration = 300
        d = EventDataStore.new(threshold, duration)

        assert_equal false, d.append("a", now)
        assert_equal false, d.append("b", now)
        assert_equal false, d.append("c", now)
        assert_equal true,  d.append("c", now)
        assert_equal true,  d.append("b", now)
        assert_equal true,  d.append("a", now)

    end

    def test_events_store

        alerts = {
            "ev1" => {
                "threshold" => 2,
                "duration" => 300
            },
            "ev2" => {
                "threshold" => 2,
                "duration" => 300
            }
        }

        now = Time.now.to_i

        es = EventsStore.new(alerts)

        assert_equal false, es.append("ev1", "a", now)
        assert_equal false, es.append("ev1", "b", now)
        assert_equal false, es.append("ev1", "c", now)
        assert_equal false, es.append("ev2", "a", now)
        assert_equal false, es.append("ev2", "b", now)
        assert_equal false, es.append("ev2", "c", now)
        assert_equal true, es.append("ev2", "a", now)
        assert_equal true, es.append("ev2", "b", now)
        assert_equal true, es.append("ev2", "c", now)
    end

end
