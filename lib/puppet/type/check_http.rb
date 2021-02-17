# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'check_http',
  docs: <<-EOS,
@summary a check_http type
@example
check_http { 'https://www.example.com': }

Use this to check whether a web server is responding correctly. This can be used both as a prerequisite (don't manage something if a dependency is unhealthy) or to check whether everything went right after managing something.
EOS
  features: [],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Set to `absent` to temporarily disable a check.',
      default: 'present',
    },
    url: {
      type: 'String',
      desc: 'The URL to test.',
      behaviour: :namevar,
    },
  },
)
