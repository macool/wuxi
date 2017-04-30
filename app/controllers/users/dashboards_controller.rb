class Users::DashboardsController < ApplicationController
  def show
    @stat_groups = {
      main_stats: get_main_stats,
      posts_stats: get_posts_stats,
      users_stats: get_users_stats,
      external_analysis_stats: get_external_analysis_stats
    }
    @active_provider_stats = get_active_providers_stats
  end

  private

  def get_active_providers_stats
    Core::ExternalProvider.active.inject({}) do |memo, external_provider|
      memo[external_provider] = get_external_provider_stats(external_provider)
      memo
    end
  end

  def get_external_provider_stats(external_provider)
    Dashboard::StatsFetcherService.for_external_provider(external_provider)
  end

  def get_users_stats
    klass = Core::ExternalUser
    klass.status.values.inject({}) do |memo, status|
      memo[status] = klass.with_status(status).count
      memo
    end
  end

  def get_main_stats
    {
      external_posts_count: Core::ExternalPost.count,
      external_users_count: Core::ExternalUser.count,
      reposts_count: Core::ExternalPost.with_status(:reposted).count
    }
  end

  def get_posts_stats
    [
      :new,
      :analysed,
      :will_repost,
      :halted_by_user_throttler,
      :trash_binned
    ].inject({}) do |memo, key|
      memo[key] = Core::ExternalPost.with_status(key).count
      memo
    end
  end

  def get_external_analysis_stats
    klass = Brain::ExternalAnalysis
    by_provider = klass.provider.values.inject({}) do |memo, provider|
      memo[provider] = klass.with_provider(provider).count
      memo
    end
    by_provider.merge(
      scheduled: Brain::ScheduledAnalysis.with_status(:new).count
    )
  end
end
