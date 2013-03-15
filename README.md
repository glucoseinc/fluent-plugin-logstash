# fluent-plugin-logstash

Format Fluentd records as Logstash events and re-emit.

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
