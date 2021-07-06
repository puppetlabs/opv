# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::CheckAptOutdated')
require 'puppet/provider/check_apt_outdated/check_apt_outdated'

RSpec.describe Puppet::Provider::CheckAptOutdated::CheckAptOutdated do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  describe 'get(context)' do
    it 'processes resources' do
      expect(provider.get(context)).to eq []
    end
  end
end
