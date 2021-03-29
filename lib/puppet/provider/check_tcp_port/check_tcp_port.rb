# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the check_tcp_port type using the Resource API.
class Puppet::Provider::CheckTcpPort::CheckTcpPort
  def get(_context)
    []
  end

  def set(context, changes)
    changes.each do |name, change|
      title = "#{name[:host]}:#{name[:port]}"
      context.processing(title, {}, {}, message: 'checking tcp port') do
        Socket.tcp(name[:host], name[:port], nil, nil, change[:should].keep_if { |k, _v| [:connect_timeout, :resolv_timeout].include?(k) }) do |_sock|
          context.info('Connection succeeded')
        end
      end
    end
  end
end
