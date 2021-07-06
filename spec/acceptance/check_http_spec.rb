# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

windows = os[:family] == 'windows'

pp_success = <<-PUPPETCODE
  check_http {'https://www.google.com':
    expected_statuses  => [200],
    body_matcher => /Google/,
    request_timeout => 30,
    retries => 3,
    backoff => 1,
    exponential_backoff_base => 2,
    max_backoff => 40,
    timeout  => 60,
  }
PUPPETCODE

pp_success_body_matcher = <<-PUPPETCODE
  check_http {'https://www.google.com':
    expected_statuses  => [200],
    body_matcher => /expected/,
    request_timeout => 30,
    retries => 3,
    backoff => 1,
    exponential_backoff_base => 2,
    max_backoff => 40,
    timeout  => 60,
  }
PUPPETCODE

pp_success_expected_statuses = <<-PUPPETCODE
  check_http {'https://www.google.com':
    expected_statuses  => [400],
    body_matcher => /expected/,
    request_timeout => 30,
    retries => 3,
    backoff => 1,
    exponential_backoff_base => 2,
    max_backoff => 40,
    timeout  => 60,
  }
PUPPETCODE

pp_failure = <<-PUPPETCODE
  check_http {'https://www.testgoogle5678.com':
    expected_statuses  => [200],
    body_matcher => /Google/,
    request_timeout => 30,
    retries => 3,
    backoff => 1,
    exponential_backoff_base => 2,
    max_backoff => 40,
    timeout  => 60,
  }
PUPPETCODE

describe 'check_http resource', unless: windows do
  context 'when check_http success idempotent' do
    it do
      idempotent_apply(pp_success)
    end
  end

  context 'when check_http success' do
    it do
      result = apply_manifest(pp_success, debug: true)
      expect(result.stdout).to contain(%(is matching with the expected_statuses))
      expect(result.stdout).to contain(%(is matching with body_matcher))
    end
  end

  context 'when check_http success doesnt match body_matcher' do
    it do
      result = apply_manifest(pp_success_body_matcher, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(is matching with the expected_statuses))
      expect(result.stdout).to contain(%(is not matching body_matcher))
      expect(result.stdout).to contain(%(1 tries))
      expect(result.stdout).to contain(%(2 tries))
      expect(result.stdout).to contain(%(3 tries))
    end
  end

  context 'when check_http success doesnt match expected_statuses' do
    it do
      result = apply_manifest(pp_success_expected_statuses, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(is not matching with the expected_statuses))
    end
  end

  context 'check_http failure verify the return' do
    it do
      result = apply_manifest(pp_failure, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(Failed to open TCP connection))
      expect(result.stdout).to contain(%(1 tries))
      expect(result.stdout).to contain(%(2 tries))
      expect(result.stdout).to contain(%(3 tries))
    end
  end
end
