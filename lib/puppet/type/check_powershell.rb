# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'check_powershell',
  docs: <<-EOS,
@summary a check_powershell type
@example
check_powershell { 'https://www.example.com': }

Use this to check whether a web server is responding correctly. This can be used both as a prerequisite (don't manage something if a dependency is unhealthy) or to check whether everything went right after managing something.
EOS
  features: ['custom_insync'],
  attributes: {
    command: {
      type: 'String',
      desc: 'The powershell command to run.',
      behaviour: :namevar,
    },
    expected_exitcode: {
      type: 'Array[Integer]',
      desc: 'An array of acceptable exit codes.',
      behaviour: :parameter,
      default: [0],
    },
    output_matcher: {
      type: 'Regexp',
      desc: 'A call is considered a success if its output matches this regular expression',
      behaviour: :parameter,
      default: %r{},
    },
    execution_timeout: {
      type: 'Numeric',
      desc: 'Number of seconds for a single execution to wait for a response to return a success before aborting.',
      behaviour: :parameter,
      default: 60,
    },
    retries: {
      type: 'Integer',
      desc: 'Number of requests to make before giving up.',
      behaviour: :parameter,
      default: 1,
    },
    backoff: {
      type: 'Numeric',
      desc: 'Initial number of seconds to wait between requests.',
      behaviour: :parameter,
      default: 10,
    },
    exponential_backoff_base: {
      type: 'Numeric',
      desc: 'Exponential base for the exponential backoff calculations.',
      behaviour: :parameter,
      default: 2,
    },
    max_backoff: {
      type: 'Numeric',
      desc: 'An upper limit to the backoff duration.',
      behaviour: :parameter,
      default: 120,
    },
    timeout: {
      type: 'Numeric',
      desc: 'Number of seconds allocated overall for the check to return a success before giving up.',
      behaviour: :parameter,
      default: 600,
    },
  },
)
