# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

ensure_module_defined('Puppet::Provider::CheckHttp')
require 'puppet/provider/check_http/check_http'

RSpec.describe Puppet::Provider::CheckHttp::CheckHttp do
  subject(:provider) { described_class.new }
  WebMock.disable_net_connect!(allow_localhost: true)

  let(:context) { double('Puppet::ResourceApi::BaseContext') }
  let(:valid_uri) { 'https://www.google.com' }
  let(:invalid_uri) { 'https://abc.test.net' }
  let(:valid_hash) { { name: 'foo', url: valid_uri, ensure: 'present',expected_statuses: [200], body_matcher: /Google/, request_timeout: 30, retries: 3, backoff: 1, exponential_backoff_base:2, max_backoff:40, timeout:60 } }
  let(:invalid_hash) { { name: 'foos', url: invalid_uri, ensure: 'present',expected_statuses: [200], body_matcher: /Google/, request_timeout: 30, retries: 3, backoff: 1, exponential_backoff_base:2, max_backoff:40, timeout:60 } }

  describe 'get(context)' do
    it 'processes resources' do
      expect(provider.get(context)).to eq []
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) without Retry' do
    it 'processes resources' do
      stub_request(:get, "https://www.google.com/").
      with(
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'www.google.com',
        'User-Agent'=>'Ruby'
        }).to_return(status: 200, body: "Google", headers: {})
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect(context).to receive(:debug).with("The return response '200' is matching with the expected_statuses '[200]'")
      expect(context).to receive(:debug).with("The return response body 'Google' is matching with body_matcher '(?-mix:Google)'")
      expect(context).to receive(:debug).with("Successfully connected to 'foo'")
      expect(provider.insync?(context, 'foo', 'foo', valid_hash, valid_hash)).to be(true)
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) expected_status not matching' do
    it 'processes resources' do
      stub_request(:get, invalid_uri).
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Host'=>'abc.test.net',
       	  'User-Agent'=>'Ruby'
           }).to_return(status: 500, body: "invalidbody", headers: {})
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(/check_http response code check failed./)
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) body_matcher not matching' do
    it 'processes resources' do
      stub_request(:get, invalid_uri).
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Host'=>'abc.test.net',
       	  'User-Agent'=>'Ruby'
           }).to_return(status: 200, body: "invalidbody", headers: {})
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      expect(context).to receive(:debug).with("The return response '200' is matching with the expected_statuses '[200]'")
      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(/check_http response body check failed./)
    end
  end

  describe 'insync?(context, name, attribute_name, is_hash, should_hash) with Retry' do
    it 'processes resources' do
      allow(context).to receive(:debug)
      allow(context).to receive(:debug)
      expect(context).to receive(:debug).with('Checking whether foo is up-to-date')
      stub_request(:get, invalid_uri).
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Host'=>'abc.test.net',
       	  'User-Agent'=>'Ruby'
           }).to_raise(StandardError)
      expect(context).to receive(:info).with(/StandardError: 'Exception from WebMock' - 1 tries/)
      expect(context).to receive(:info).with(/StandardError: 'Exception from WebMock' - 2 tries/)
      expect(context).to receive(:info).with(/StandardError: 'Exception from WebMock' - 3 tries/)

      expect { provider.insync?(context, 'foo', 'foo', invalid_hash, invalid_hash) }.to raise_error(StandardError)
    end
  end
end
