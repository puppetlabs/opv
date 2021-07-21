# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

windows = os[:family] == 'windows'

pp_success = <<-PUPPETCODE
  check_powershell {'$PSVersionTable.PSVersion':
    expected_exitcode => [0],
    output_matcher => /5/,
    retries => 2,
   }
PUPPETCODE

pp_success_body_matcher = <<-PUPPETCODE
  check_powershell {'$PSVersionTable.PSVersion':
    expected_exitcode => [0],
    output_matcher => /notmatching/,
    retries => 2,
}
PUPPETCODE

pp_success_expected_statuses = <<-PUPPETCODE
  check_powershell {'$PSVersionTable.PSVersion':
    expected_exitcode => [2],
    output_matcher => /5/,
    retries => 2,
}
PUPPETCODE

pp_failure = <<-PUPPETCODE
  check_powershell {'invalid$PSVersionTable.PSVersion':
    expected_exitcode => [0],
    output_matcher => /notmatching/,
    retries => 2,
}
PUPPETCODE

describe 'check_powershell resource', if: windows do
  context 'when check_powershell success idempotent' do
    it do
      idempotent_apply(pp_success)
    end
  end

  context 'when check_powershell success' do
    it do
      result = apply_manifest(pp_success, debug: true)
      expect(result.stdout).to contain(%(is matching with the expected_exitcode))
      expect(result.stdout).to contain(%(is matching with output_matcher))
    end
  end

  context 'when check_powershell success doesnt match body_matcher' do
    it do
      result = apply_manifest(pp_success_body_matcher, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(is matching with the expected_exitcode))
      expect(result.stdout).to contain(%(is not matching body_matcher))
      expect(result.stdout).to contain(%(1 tries))
      expect(result.stdout).to contain(%(2 tries))
      expect(result.stdout).to contain(%(3 tries))
    end
  end

  context 'when check_powershell success doesnt match expected_statuses' do
    it do
      result = apply_manifest(pp_success_expected_statuses, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(is not matching with the expected_exitcode))
    end
  end

  context 'check_powershell failure verify the return' do
    it do
      result = apply_manifest(pp_failure, debug: true, expect_failures: true, acceptable_exit_codes: [4])
      expect(result.stdout).to contain(%(Failed to open TCP connection))
      expect(result.stdout).to contain(%(1 tries))
      expect(result.stdout).to contain(%(2 tries))
      expect(result.stdout).to contain(%(3 tries))
    end
  end
end
