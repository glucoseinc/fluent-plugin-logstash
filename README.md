# fluent-plugin-logstash

Format Fluentd records as Logstash events and re-emit.

The re-emitted record conforms to logstash's 'json_event' format and is mapped from the original record in the following fashion:

    {
        '@timestamp' => time.as(ISO8601),
        '@type' => resolve_logstash_type(tag, conf['logstash_type']),
        '@fields'=> conf['logstash_fields'].as_dict + record.without('message'),
        '@tags' => conf['logstash_tags'].split(' '),
        '@message' => record['message'] if record.include? 'message',
    }

## Config options

    <match **>
      type logstash
      tag some.tag        # override the tag or,
      remove_prefix raw   # remove prefix from tag
      add_prefix logstash # add prefix to tag
      logstash_type "%{final}" # use the final value of the tag as logstash event type
                               # valid directives: %{original} %{removed} %{added} %{final}
      logstash_tags "add_me as_tags"
      logstash_fields "add_this_field_name as_field_value another_field with_value"
    </match>
