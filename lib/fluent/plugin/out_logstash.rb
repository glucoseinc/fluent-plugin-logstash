ISO8601_STRFTIME = "%04d-%02d-%02dT%02d:%02d:%02d.%06d%+03d:00".freeze

class Fluent::LogstashOutput < Fluent::Output
  Fluent::Plugin.register_output('logstash', self)

  config_param :tag, :string, :default => nil
  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil
  config_param :logstash_type, :string, :default => '%{final}' # %{original} %{removed} %{added} %{final}
  config_param :logstash_tags, :string, :default => nil
  config_param :logstash_fields, :string, :default => nil
  
  def configure(conf)
    super
    
    if not @tag and not @remove_prefix and not @add_prefix
      raise Fluent::ConfigError, "missing both of remove_prefix and add_prefix"
    end
    if @tag and (@remove_prefix or @add_prefix)
      raise Fluent::ConfigError, "both of tag and remove_prefix/add_prefix must not be specified"
    end
    if @remove_prefix
      @removed_prefix_string = @remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    if @add_prefix
      @added_prefix_string = @add_prefix + '.'
    end
    if @logstash_tags
      @logstash_tags_list = @logstash_tags.split(' ')
    end
    if @logstash_fields
      @logstash_fields_dict = Hash[*@logstash_fields.split(' ')]
    end
  end

  def resolve_tag(tag)
    stages = {:original => tag}
    if @tag
      stages[:final] = @tag
    else
      if @remove_prefix and
          ( (tag.start_with?(@removed_prefix_string) and tag.length > @removed_length) or tag == @remove_prefix)
        tag = stages[:removed] = tag[@removed_length..-1]
      end 
      if @add_prefix 
        tag = stages[:added] = if tag and tag.length > 0
                @added_prefix_string + tag
              else
                @add_prefix
              end
      end
      stages[:final] = tag
    end
    stages
  end

  def format_time(epochtime)
    time = Time.at(epochtime)
    return sprintf(ISO8601_STRFTIME, time.year, time.month, time.day, time.hour,
                   time.min, time.sec, time.tv_usec, time.utc_offset / 3600)
  end

  def emit(tag, es, chain)
    tag_stages = resolve_tag(tag)
    tag = tag_stages[:final]
    es.each do |time,record|
      logstash_event = {
        '@timestamp' => format_time(time),
        '@type' => @logstash_type % tag_stages,
        '@fields' => {},
      }
      logstash_event['@fields'].merge! @logstash_fields_dict if @logstash_fields_dict
      logstash_event['@tags'] = @logstash_tags_list if @logstash_tags_list
      record.each do |k,v|
        case k
        when 'message'
          logstash_event['@message'] = v
        else
          logstash_event['@fields'][k] = v
        end
      end

      logstash_event['@message'] = '' unless logstash_event.include? '@message'

      Fluent::Engine.emit(tag, time, logstash_event)
    end

    chain.next
  end
end
