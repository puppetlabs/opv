# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::CheckPowershell')
require 'puppet/provider/check_powershell/check_powershell'

RSpec.describe Puppet::Provider::CheckPowershell::CheckPowershell do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext') }
  let(:posh) { instance_double('Pwsh::Manager') }
  let(:valid_command) { '$PSVersionTable.PSVersion' }
  let(:invalid_command) { 'invalid$PSVersion' }
  let(:execute_valid_command) { 'try { $PSVersionTable.PSVersion; exit $LASTEXITCODE } catch { write-error $_ ; exit 1 }' }
  let(:execute_invalid_command) { 'try { invalid$PSVersion; exit $LASTEXITCODE } catch { write-error $_ ; exit 1 }' }
  let(:valid_hash) do
    { name: 'foo', command: valid_command, expected_exitcode: [0], output_matcher: %r{Major}, request_timeout: 30, retries: 1, backoff: 1, exponential_backoff_base: 2, max_backoff: 40, timeout: 60 }
  end
  let(:invalid_hash) do
    { name: 'foos', command: invalid_command, expected_exitcode: [2], output_matcher: %r{test}, request_timeout: 30, retries: 3, backoff: 1, exponential_backoff_base: 2, max_backoff: 40, timeout: 60 }
  end

  describe 'get(context)' do
    it 'processes resources' do
      expect(provider.get(context)).to eq []
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) without Retry' do
    it 'processes resources' do
      allow(Pwsh::Manager).to receive(:powershell_path).and_return('C:\\Windows')
      allow(Pwsh::Manager).to receive(:powershell_args).and_return(['-NoProfile'])
      allow(Pwsh::Manager).to receive(:instance).with(any_args).and_return(posh)
      allow(posh).to receive(:execute).with(execute_valid_command).and_return({ stdout: 'Major', exitcode: 0 })
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect(context).to receive(:debug).with("The return exitcode '0' is matching with the expected_exitcode '[0]'")
      expect(context).to receive(:debug).with("The return output 'Major' is matching with output_matcher '(?-mix:Major)'")
      expect(context).to receive(:debug).with("Successfully executed the command '$PSVersionTable.PSVersion'")
      expect(provider.insync?(context, 'foo', 'foo', valid_hash, valid_hash)).to be(true)
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) expected_exitcode not matching' do
    it 'processes resources' do
      allow(Pwsh::Manager).to receive(:powershell_path).and_return('C:\\Windows')
      allow(Pwsh::Manager).to receive(:powershell_args).and_return(['-NoProfile'])
      allow(Pwsh::Manager).to receive(:instance).with(any_args).and_return(posh)
      allow(posh).to receive(:execute).with(execute_invalid_command).and_return({ stdout: 'Major', exitcode: 3 })
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect(context).to receive(:info).with(%r{1 tries})
      expect(context).to receive(:info).with(%r{2 tries})
      expect(context).to receive(:info).with(%r{3 tries})
      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(%r{check_powershell exitcode check failed.})
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) output_matcher not matching' do
    it 'processes resources' do
      allow(Pwsh::Manager).to receive(:powershell_path).and_return('C:\\Windows')
      allow(Pwsh::Manager).to receive(:powershell_args).and_return(['-NoProfile'])
      allow(Pwsh::Manager).to receive(:instance).with(any_args).and_return(posh)
      allow(posh).to receive(:execute).with(execute_invalid_command).and_return({ stdout: 'invalid', exitcode: 2 })
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect(context).to receive(:debug).with("The return exitcode '2' is matching with the expected_exitcode '[2]'")
      expect(context).to receive(:info).with(%r{1 tries})
      expect(context).to receive(:info).with(%r{2 tries})
      expect(context).to receive(:info).with(%r{3 tries})
      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(%r{check_powershell output check failed.})
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) with Retry' do
    it 'processes resources' do
      allow(Pwsh::Manager).to receive(:powershell_path).and_return('C:\\Windows')
      allow(Pwsh::Manager).to receive(:powershell_args).and_return(['-NoProfile'])
      allow(Pwsh::Manager).to receive(:instance).with(any_args).and_return(posh)
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      allow(posh).to receive(:execute).with(execute_invalid_command).and_raise(StandardError)
      expect(context).to receive(:info).with(%r{1 tries})
      expect(context).to receive(:info).with(%r{2 tries})
      expect(context).to receive(:info).with(%r{3 tries})
      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(StandardError)
    end
  end
end
