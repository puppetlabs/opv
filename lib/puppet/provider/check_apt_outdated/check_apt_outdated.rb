# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the check_apt_outdated type using the Resource API.
class Puppet::Provider::CheckAptOutdated::CheckAptOutdated
  def get(_context)
    []
  end

  def set(context, changes)
  end

  def insync?(context, name, attribute_name, is_hash, should_hash)
    context.debug("Checking whether #{attribute_name} is up-to-date")
    pkgcache_stat = File::Stat.new('/var/cache/apt/pkgcache.bin')

    # Time differences come back in seconds
    pkgcache_age_days = (Time.new - pkgcache_stat.mtime) / 60 / 60 / 24
    if pkgcache_age_days > should_hash[:allowed_pkgcache_age_days] # rubocop:disable Style/GuardClause
      raise Puppet::Error, "/var/cache/apt/pkgcache.bin has been updated last #{pkgcache_age_days} days ago (expected allowed_pkgcache_age_days no more than #{should_hash[:allowed_pkgcache_age_days]} days)."
    else
      context.info("/var/cache/apt/pkgcache.bin has been updated within configured range of #{should_hash[:allowed_pkgcache_age_days]} days (last update is #{pkgcache_age_days} days ago).")
    end

    apt_list_stats_by_mtime = Dir['/var/lib/apt/lists/*'].map { |f| OpenStruct.new(file: f, stat: File::Stat.new(f)) }.select { |f| f.stat.file? }.group_by { |f| f.stat.mtime }
    apt_list_oldest_mtime = apt_list_stats_by_mtime.keys.min
    oldest_apt_list_names = apt_list_stats_by_mtime[apt_list_oldest_mtime].map { |f| f.file }.join(', ')

    # Time differences come back in seconds
    mirror_age_days = (Time.new - apt_list_oldest_mtime) / 60 / 60 / 24
    if mirror_age_days > should_hash[:allowed_mirror_age_days] # rubocop:disable Style/GuardClause
      raise Puppet::Error, "upstream mirror has been updated last #{mirror_age_days} days ago (expected allowed_mirror_age_days no more than #{should_hash[:allowed_mirror_age_days]}; files: #{oldest_apt_list_names})."
    else
      context.info("upstream mirrors have all been updated within configured range of #{should_hash[:allowed_mirror_age_days]} days (oldest update is #{mirror_age_days} days ago).")
    end
  end
end
