require "core/external_posts/populate_task/populate_twitter/saver"

module Core
  class ExternalPosts
    class PopulateTask
      class PopulateTwitter
        def initialize(external_provider)
          @external_provider = external_provider
        end

        def run
          @saved = 0
          analyse_search_results!
          log "saved #{@saved} posts for #{@external_provider} (searchterm: #{@external_provider.account.searchterm})"
        end

        private

        def log(str)
          Rails.logger.info "[#{self.class}] #{str}"
        end

        def analyse_search_results!
          search_results.each do |tweet|
            if save?(tweet)
              @saved += 1
            end
            if @saved >= collector_size
              log "WARN: exceeded collector size #{collector_size}"
              return
            end
          end
        end

        def search_results
          last_post = @external_provider.posts.latest.first
          log "searching #{@external_provider.account.searchterm}"
          twitter_client.search(
            @external_provider.account.searchterm,
            result_type: "recent",
            count: collector_size,
            since_id: last_post.try(:uid) # may be empty
          )
        rescue Twitter::Error::Unauthorized => e
          Airbrake.notify(e, parameters: {
            account: @external_provider.account.name,
            account_id: @external_provider.account.id,
            external_provider_id: @external_provider.id,
            external_provider_uid: @external_provider.uid
          })
        end

        def save?(tweet)
          Saver.new(tweet: tweet, external_provider: @external_provider).save
        end

        def twitter_client
          ExternalProvider::TwitterClientService.from_external_provider(
            @external_provider
          ).twitter_client
        end

        def collector_size
          Rails.application.secrets.collector_size
        end
      end
    end
  end
end
