module Stripe
  class WebhookHandler
    def initialize(event)
      @event = event
    end

    def handle
      return :unknown unless known_event?
      send(event_mappings[@event.type])
    end

    private

    def event_mappings
      {
        "account.application.deauthorized" => :deauthorize
      }
    end

    def known_event?
      event_mappings.keys.include? @event.type
    end

    def deauthorize
      return :ignored unless @event.respond_to?(:account)
      destroyed = destroy_stripe_accounts_linked_to(@event.account)
      destroyed.any? ? :success : :ignored
    end

    def destroy_stripe_accounts_linked_to(account)
      StripeAccount.where(stripe_user_id: account).destroy_all
    end
  end
end
