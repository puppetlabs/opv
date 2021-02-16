# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/tcp_port_reachable'

RSpec.describe 'the tcp_port_reachable type' do
  it 'loads' do
    expect(Puppet::Type.type(:tcp_port_reachable)).not_to be_nil
  end
end
