require 'redis'
require 'redis-objects'

module Datapimp::Filterable::CacheStatistics
  extend ActiveSupport::Concern

  def cache_stats_report
    tracker = cache_stats_tracker

    {
      cache_miss_count: tracker.cache_misses.to_i,
      cache_hit_count: tracker.cache_hits.to_i,
      ratio: tracker.ratio
    }
  end

  def cache_stats_tracker
    self.class.cache_stats_tracker
  end

  def record_cache_hit(cache_key)
    cache_stats_tracker.hit(cache_key)
  end

  def record_cache_miss(cache_key)
    cache_stats_tracker.miss(cache_key)
  end

  def clear_cache_stats
    cache_stats_tracker.clear
  end

  module ClassMethods
    def cache_stats_tracker
      @cache_stats_tracker ||= Tracker.new(self.to_s)
    end
  end

  class Tracker
    include Redis::Objects

    counter :cache_hits
    counter :cache_misses
    counter :queries

    set :cache_keys

    # TODO
    # Make this more configurable
    self.redis = Redis.new

    def initialize(filter_context_class)
      @context_class = filter_context_class.to_s
    end

    def clear
      queries.clear
      cache_hits.clear
      cache_misses.clear
      cache_keys.clear
    end

    def ratio
      return 100.0 if queries == 0
      value = (cache_misses.to_i / queries.to_i.to_f) * 100
      '%.2f' % value
    end

    def miss(cache_key)
      increment(:queries)
      increment(:cache_misses)
      cache_keys << cache_key
    end

    def hit(cache_key)
      increment(:queries)
      increment(:cache_hits)
      cache_keys << cache_key
    end

    def id
      @id ||= "#{ ::Rails.env }:#{ @context_class.underscore }"
    end
  end
end
