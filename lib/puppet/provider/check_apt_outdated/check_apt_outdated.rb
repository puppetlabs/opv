# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the check_apt_outdated type using the Resource API.
class Puppet::Provider::CheckAptOutdated::CheckAptOutdated
  def get(_context)
    []
  end

  def set(context, changes)
    params = changes.first[:should]
    pkgcache_stat = File::Stat.new('/var/cache/apt/pkgcache.bin')

    # Time differences come back in seconds
    pkgcache_age_days = (Time.new - pkgcache_stat.mtime) / 60 / 60 / 24
    if pkgcache_age_days > params[:allowed_pkgcache_age_days] # rubocop:disable Style/GuardClause
      raise Puppet::Error, "/var/cache/apt/pkgcache.bin has been updated last #{pkgcache_age_days} days ago (expected no more than #{params[:allowed_pkgcache_age_days]} days)."
    else
      context.info("/var/cache/apt/pkgcache.bin has been updated within configured range of #{params[:allowed_pkgcache_age_days]} days (last update is #{pkgcache_age_days} days ago).")
    end

    apt_list_stats_by_mtime = Dir['/var/lib/apt/lists/*'].map { |f| File::Stat.new(f) }.select { |f| f.file? }.group_by { |f| f.mtime }
    apt_list_oldest_mtime = apt_list_stats_by_mtime.keys.min
    oldest_apt_list = apt_list_stats_by_mtime[apt_list_oldest_mtime].join(', ')

    # Time differences come back in seconds
    mirror_age_days = (Time.new - apt_list_oldest_mtime) / 60 / 60 / 24
    if mirror_age_days > params[:allowed_mirror_age_days] # rubocop:disable Style/GuardClause
      raise Puppet::Error, "upstream mirror has been updated last #{mirror_age_days} days ago (expected no more than #{params[:allowed_mirror_age_days]}; files: #{oldest_apt_list})."
    else
      context.info("upstream mirrors have all been updated within configured range of #{params[:allowed_mirror_age_days]} days (oldest update is #{mirror_age_days} days ago).")
    end
  end
end
