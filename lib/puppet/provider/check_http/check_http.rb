# frozen_string_literal: true

require 'net/http'

# Implementation for the check_http type using the Resource API.
class Puppet::Provider::CheckHttp::CheckHttp
  def get(_context)
    []
  end

  def set(context, changes)
    changes.each do |name, _change|
      uri = URI(name)
      context.processing(uri.to_s, {}, {}, message: 'checking http') do
        if Net::HTTP.get(uri)
          context.info("successfully connected to #{name}")
        end
      end
    end
  end
end
