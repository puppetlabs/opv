# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'tcp_port_reachable',
  docs: <<-EOS,
@summary Checks if the specified port is reachable over TCP.
@example
tcp_port_reachable { '127.0.0.1:22': }

This type provides Puppet with the capability to check ports for TCP connectivity.
EOS
  features: [],
  title_patterns: [
    {
      pattern: %r{^(?<host>.+):(?<port>[0-9]+)$},
      desc: 'host:port',
    },
  ],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Set to `absent` to temporarily disable a check.',
      default: 'present',
    },
    host: {
      type: 'String',
      desc: 'The host or IP to check.',
      behaviour: :namevar,
    },
    port: {
      type: 'String',
      desc: 'The port to check.',
      behaviour: :namevar,
    },
    connect_timeout: {
      type: 'Numeric',
      desc: 'specify the timeout in seconds.',
      default: 10,
    },
    resolv_timeout: {
      type: 'Numeric',
      desc: 'specify the name resolution timeout in seconds.',
      default: 10,
    },
  },
)
