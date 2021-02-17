# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/check_http'

RSpec.describe 'the check_http type' do
  it 'loads' do
    expect(Puppet::Type.type(:check_http)).not_to be_nil
  end
end
