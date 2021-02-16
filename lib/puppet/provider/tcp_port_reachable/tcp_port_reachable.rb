# frozen_string_literal: true

# Implementation for the tcp_port_reachable type using the Resource API.
class Puppet::Provider::TcpPortReachable::TcpPortReachable
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
