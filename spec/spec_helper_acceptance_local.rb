# frozen_string_literal: true


class LitmusHelper
  include Singleton
  include PuppetLitmus
end

class OpvHelper
  include Singleton
  RSpec.configure do |c|
    if ENV['CI'] == 'true'
      c.filter_run_excluding
    end
    c.before :suite do
      # Make sure selinux is disabled so the tests work.
      LitmusHelper.instance.run_shell('setenforce 0', expect_failures: true) if %r{redhat|oracle}.match?(os[:family])
      LitmusHelper.instance.run_shell('/opt/puppetlabs/puppet/bin/gem install retriable') unless %r{windows}.match?(os[:family])
    end
  end
end