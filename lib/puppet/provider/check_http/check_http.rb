# frozen_string_literal: true

require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'net/http'
require 'retriable'

# Implementation for the check_http type using the Resource API.
class Puppet::Provider::CheckHttp::CheckHttp
  def get(_context)
    []
  end

  def set(context, changes); end

  # Update the check_http provider to use the above attributes to execute up to retries number of times
  # with success being defined as having one of the expected_statuses
  # and the body of the response matches body_matcher while taking into account request_timeout.

  def insync?(context, name, attribute_name, _is_hash, should_hash)
    context.debug("Checking whether #{attribute_name} is up-to-date")
    uri = URI.parse(should_hash[:url])

    # This callback provides the exception that was raised in the current try, the try_number, the elapsed_time for all tries so far, and the time in seconds of the next_interval.
    do_this_on_each_retry = proc do |exception, try, elapsed_time, next_interval|
      context.info("#{exception.class}: '#{exception.message}' - #{try} tries in #{elapsed_time} seconds and #{next_interval} seconds until the next try.") unless exception.nil?
    end

    Retriable.retriable(tries: should_hash[:retries], max_elapsed_time: should_hash[:request_timeout], max_interval: should_hash[:max_backoff],
multiplier: should_hash[:exponential_backoff_base], on_retry: do_this_on_each_retry) do
      response = Net::HTTP.get_response(uri)

      unless should_hash[:expected_statuses].include? response.code.to_i
        raise Puppet::Error, "check_http response code check failed. The return response '#{response.code}' is not matching with the expected_statuses '#{should_hash[:expected_statuses]}.to_s'"
      end
      context.debug("The return response '#{response.code}' is matching with the expected_statuses '#{should_hash[:expected_statuses]}'")
      unless response.body.match(should_hash[:body_matcher])
        raise Puppet::Error, "check_http response body check failed. The return response body '#{response.body[0..99]}' is not matching body_matcher '#{should_hash[:body_matcher].to_s}'"
      end
      context.debug("The return response body '#{response.body[0..99]}' is matching with body_matcher '#{should_hash[:body_matcher].to_s}'")
      context.debug("Successfully connected to '#{name}'")
      return true
    end
    false
  end
end
