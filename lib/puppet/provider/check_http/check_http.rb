# frozen_string_literal: true

require 'net/http'
require 'pry'
require 'retriable'

# Implementation for the check_http type using the Resource API.
class Puppet::Provider::CheckHttp::CheckHttp
  def get(_context)
    []
  end

  def set(context, changes)
  end

  # Update the check_http provider to use the above attributes to execute up to retries number of times 
  # with success being defined as having one of the expected_statuses 
  # and the body of the response matches body_matcher while taking into account request_timeout.

  def insync?(context, name, attribute_name, is_hash, should_hash)
    context.debug("Checking whether #{attribute_name} is up-to-date")
    should_hash.each do |name, change|
      #binding.pry
      uri = URI(change)
      context.processing(uri.to_s, {}, {}, message: 'checking http') do
        Retriable.configure do |c|
          #binding.pry
          # Execute up to retries number of times
          c.tries = should_hash[:retries]

          c.max_elapsed_time = should_hash[:request_timeout]
          # Update the check_http provider to wait for backoff ** (exponential_backoff_base * (retries - 1) seconds between attempts (up to max_backoff)
          c.base_interval = should_hash[:backoff] ** (should_hash[:exponential_backoff_base] * should_hash[:retries] - 1)
          c.max_interval = should_hash[:max_backoff]

          binding.pry
          response = Net::HTTP.get_response(uri)
          # Success being defined as having one of the expected_statuses and the body of the response matches body_matcher
          if (should_hash[:expected_statuses].include? response.code) && (response.message.match(should_hash[:body_matcher]))
            context.info("successfully connected to #{name}")
          end
        end
      end
    end
  end
end