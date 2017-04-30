class Dashboard::StatsFetcherService
  def self.for_external_provider(external_provider)
    new(external_provider: external_provider).stats
  end

  def initialize(external_provider:)
    @external_provider = external_provider
  end

  def stats
    [
      :tweets,
      :analysed,
      :will_repost,
      :reposted
    ].inject({}) do |memo, stat_name|
      memo[stat_name] = send(stat_name)
      memo
    end
  end

  private

  def tweets
    external_posts.count
  end

  def analysed
    external_posts_with_status :analysed
  end

  def will_repost
    external_posts_with_status :will_repost
  end

  def reposted
    external_posts_with_status :reposted
  end

  def external_posts_with_status(status)
    external_posts.with_status(status).count
  end

  def external_posts
    Core::ExternalPost.where(external_provider: @external_provider)
  end
end
