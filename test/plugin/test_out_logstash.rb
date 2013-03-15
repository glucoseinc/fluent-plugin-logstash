require 'helper'

class ParserOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end
  
  CONFIG = %[
    remove_prefix foo.baz
    add_prefix foo.bar
    logstash_type %{original}
    logstash_fields add me
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::LogstashOutput, tag).configure(conf)
  end

  def test_emit_uwsgi_fallback_ltsv
    d = create_driver(CONFIG, 'foo.baz.test')
    time = Time.parse("2012-04-02 18:20:59").to_i
    d.run do
      d.emit({'message' => "some message", 'xxx' => 'x', 'yyy' => 'y'}, time)
    end
    emits = d.emits
    assert_equal 1, emits.length

    record = emits[0]
    assert_equal 'foo.bar.test', record[0]
    assert_equal time, record[1]
    assert_nil record[2]['message']
    assert_equal 'some message', record[2]['@message']
    assert_equal 'foo.baz.test', record[2]['@type']
    assert_equal '2012-04-02T18:20:59.000000+09:00', record[2]['@timestamp']
    assert_equal 'x', record[2]['@fields']['xxx']
    assert_equal 'y', record[2]['@fields']['yyy']
    assert_equal 'me', record[2]['@fields']['add']
  end

end
