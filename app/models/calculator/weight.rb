require 'spree/localized_number'

module Calculator
  class Weight < Spree::Calculator
    extend Spree::LocalizedNumber
    preference :per_kg, :decimal, default: 0.0
    attr_accessible :preferred_per_kg
    localize_number :preferred_per_kg

    def self.description
      I18n.t('spree.weight')
    end

    def compute(object)
      line_items = line_items_for object
      total_weight(line_items) * preferred_per_kg
    end

    def total_weight(line_items)
      line_items.sum do |line_item|
        if line_item.final_weight_volume.present?
          line_item.final_weight_volume / 1000
        else
          (line_item.variant.andand.weight || 0) * line_item.quantity
        end
      end
    end
  end
end
