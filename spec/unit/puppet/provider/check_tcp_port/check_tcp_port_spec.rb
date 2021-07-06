# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::CheckTcpPort')
require 'puppet/provider/check_tcp_port/check_tcp_port'

RSpec.describe Puppet::Provider::CheckTcpPort::CheckTcpPort do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  describe 'get(context)' do
    it 'processes resources' do
      expect(provider.get(context)).to eq []
    end
  end
end
