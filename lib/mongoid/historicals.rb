require 'mongoid'
require_relative 'historicals/version'
require_relative 'historicals/record'

module Mongoid
  module Historicals
    extend ActiveSupport::Concern

    included do
      embeds_many :historicals,
        class_name: "Mongoid::Historicals::Record"

      class_attribute :historical_attributes
      class_attribute :historical_options
    end

    # Save the current values for historicals by label
    #
    def record!(label = nil)
      label ||= Time.now
      record = self.historicals.build(:'_label' => labelize(label))

      self.class.historical_attributes.each do |attr|
        record[attr] = self.send(attr)
      end

      record.save!
      destroy_old_historicals!
      record
    end

    def historical(label)
      self.historicals.where(:'_label' => labelize(label)).first
    end

    def historical_difference(attr, label, options = {})
      opts = {
        default: 0
      }.merge(options)

      record = historical(labelize(label))

      begin
        self[attr] - record[attr]
      rescue # Pokemon exception handling, but actually seems appropriate here
        opts[:default]
      end
    end

    private

      def labelize(label)
        if label.is_a?(String) || label.is_a?(Symbol)
          label.to_s
        elsif label.respond_to?(:to_datetime)
          dt = label.to_datetime

          case self.class.historical_options[:frequency]
          when :monthly
            dt.strftime("%Y/%m")
          when :weekly
            dt.strftime("%G-%V")
          else # default to `:daily`
            dt.strftime("%Y/%m/%d")
          end
        else
          raise("`label` must be a String, Symbol or respond to :to_datetime")
        end
      end

      def destroy_old_historicals!
        if self.class.historical_options[:max]
          records = self.historicals.asc(:created_at)
          
          if (num_to_delete = records.size - self.class.historical_options[:max]) > 0
            records[0, num_to_delete].each do |r|
              self.historicals.delete(r)
            end
          end
        end
      end

    module ClassMethods

      # This model should record historical values for the specified
      # attributes.
      #
      # Options:
      # 
      #   <tt>max</tt>: The maximum number of entries to store (default: none)
      #   <tt>frequency</tt>: :monthly, :weekly, or :daily (default: :daily)
      #
      def historicals(*attrs)
        options = attrs.extract_options!
        options[:max] ||= nil
        options[:frequency] ||= :daily

        self.historical_options = options
        self.historical_attributes = attrs
      end
    end
  end
end
