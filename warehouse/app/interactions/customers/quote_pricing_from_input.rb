require 'active_interaction'

module Customers
  # Interaction to quote customers on the pricing of storing their items
  class QuotePricingFromInput < ActiveInteraction::Base
    object :customer, class: Customer

    string :input

    validate :valid_json
    validate :valid_items

    def execute
      json_data = JSON.parse(input)['items']
      items = json_data.map { |item_params| Item.new(item_params) }

      ::CustomerHelper::PriceQuoter.quote_pricing(customer, items)
    end

    private

    # Validation
    def valid_json
      JSON.parse(input)
    rescue JSON::ParserError, TypeError
      raise ActiveInteraction::InvalidInteractionError, 'input is not a valid json'
    end

    def valid_items
      json_data = JSON.parse(input)['items']

      errors.add(:input, 'input contains invalid items') unless json_data.map { |item|
        Item.new(item.merge(customer: customer))
      }.all?(&:valid?)
    end
  end
end
