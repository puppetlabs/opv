# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/check_powershell'

RSpec.describe 'the check_powershell type' do
  it 'loads' do
    expect(Puppet::Type.type(:check_powershell)).not_to be_nil
  end
end
