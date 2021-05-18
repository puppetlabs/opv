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
  features: ['custom_insync'],
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
    headers: {
      type: 'Hash[String, String]',
      desc: 'A hash of headers to pass along with the request.',
      behaviour: :parameter,
      default: {},
    },
    expected_statuses: {
      type: 'Array[Integer]',
      desc: 'An array of acceptable HTTP status codes. If a request returns one of these status codes, it is considered a success',
      behaviour: :parameter,
      default: 200,
    },
    body_matcher: {
      type: 'Regexp',
      desc: 'A request is considered a success if the body of the HTTP response matches this regular expression',
      behaviour: :parameter,
      default: //,
    },
    request_timeout: {
      type: 'Numeric',
      desc: 'Number of seconds for a single request to wait for a response to return a success before aborting.',
      behaviour: :parameter,
      default: 10,
    },
    retries: {
      type: 'Integer',
      desc: 'Number of requests to make before giving up.',
      behaviour: :parameter,
      default: 3,
    },
    backoff: {
      type: 'Numeric',
      desc: 'Initial number of seconds to wait between requests.',
      behaviour: :parameter,
      default: 1,
    },
    exponential_backoff_base: {
      type: 'Numeric',
      desc: 'Exponential base for the exponential backoff calculations.',
      behaviour: :parameter,
      default: 2,
    },
    max_backoff: {
      type: 'Numeric',
      desc: 'An upper limit to the backoff duration,.',
      behaviour: :parameter,
      default: 10,
    },
    timeout: {
      type: 'Numeric',
      desc: 'Number of seconds allocated overall for the check to return a success before giving up.',
      behaviour: :parameter,
      default: 60,
    },
  },
)
