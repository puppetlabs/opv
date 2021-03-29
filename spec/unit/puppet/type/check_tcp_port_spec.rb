# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/check_tcp_port'

RSpec.describe 'the check_tcp_port type' do
  it 'loads' do
    expect(Puppet::Type.type(:check_tcp_port)).not_to be_nil
  end
end
