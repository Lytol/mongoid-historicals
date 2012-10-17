require 'mongoid'
require_relative 'historicals/version'
require_relative 'historicals/record'

module Mongoid
  module Historicals
    extend ActiveSupport::Concern

    included do
      embeds_many :historical_records,
        class_name: "Mongoid::Historicals::Record"

      class_attribute :historical_attributes
      class_attribute :historical_options
    end

    # Save the current values for historicals by name
    #
    def record!(name)
      record = self.historical_records.build(:'_name' => name)

      self.class.historical_attributes.each do |attr|
        record[attr] = self.send(attr)
      end

      record.save!
    end

    module ClassMethods

      # This model should record historical values for the specified
      # attributes.
      #
      # Options:
      # 
      #   <tt>max</tt>: The maximum number of entries to store
      #
      def historicals(*attrs)
        options = attrs.extract_options!
        options[:max] ||= nil

        self.historical_options = options
        self.historical_attributes = attrs
      end
    end
  end
end
