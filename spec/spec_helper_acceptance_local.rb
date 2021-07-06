# frozen_string_literal: true


class LitmusHelper
  include Singleton
  include PuppetLitmus
end

class OpvHelper
  include Singleton
  RSpec.configure do |c|
    # IPv6 is not enabled by default in the new travis-ci Trusty environment (see https://github.com/travis-ci/travis-ci/issues/8891 )
    if ENV['CI'] == 'true'
      c.filter_run_excluding ipv6: true
    end
    c.before :suite do
      # Make sure selinux is disabled so the tests work.
      LitmusHelper.instance.run_shell('setenforce 0', expect_failures: true) if %r{redhat|oracle}.match?(os[:family])
      LitmusHelper.instance.run_shell('/opt/puppetlabs/puppet/bin/gem install retriable')
    end
  end
end