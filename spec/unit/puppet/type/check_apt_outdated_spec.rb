# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/check_apt_outdated'

RSpec.describe 'the check_apt_outdated type' do
  it 'loads' do
    expect(Puppet::Type.type(:check_apt_outdated)).not_to be_nil
  end
end
