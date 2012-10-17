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

    # Save the current values as a historical record
    #
    # @param [String, #to_datetime] label The label as a String, Symbol or DateTime that the historical record will be saved as. If you pass a DateTime object, it
    #   will use the <tt>:frequency</tt> option from historicals to save as a date/time.
    # @return [Record] the historical record that is saved
    def record!(label = nil)
      label ||= Time.now
      record = historical(label) || self.historicals.build(:'_label' => labelize(label))

      self.class.historical_attributes.each do |attr|
        record[attr] = self.send(attr)
      end

      record.save!
      destroy_old_historicals!
      record
    end

    # Retrieve the historical record or a single attribute value from the 
    # specified label. If only one argument is given, it will return
    # the entire record with that label. If two arguments are given, the 
    # first argument will specify the attribute and the second argument is the
    # label to use.
    #
    # @param [String, #to_datetime] attr_or_label If only one argument is given, 
    #   this is the <tt>label</tt> for the record to be returned. If two arguments 
    #   are given, this should be the symbol of the attribute whose value should 
    #   be returned.
    # @return With one argument given, the historical record or nil if none 
    #   exists. With two arguments given, it should return the value of the 
    #   requested attribute for the specified label.
    def historical(attr_or_label, label = nil)
      if label.nil?
        self.historicals.where(:'_label' => labelize(attr_or_label)).first
      else
        record = self.historicals.where(:'_label' => labelize(label)).first

        if record
          record[attr_or_label]
        else
          nil
        end
      end
    end

    # Return the difference between the current value of the attribute and the value of attribute from the 
    # <tt>label</tt> historical record.
    #
    # @param [Symbol] attr The attribute on which you are calculating the difference
    # @param [String, Symbol, #to_datetime] label The label as a String, Symbol or Datetime for the historical record against which you are comparing
    # @param [Hash] options
    # @option options [Object] :default The value you want returned if there is no historical for comparison (default: 0)
    def historical_difference(attr, label, options = {})
      opts = {
        default: 0
      }.merge(options)

      begin
        self[attr] - historical(attr, label)
      rescue # Pokemon exception handling, but actually seems appropriate here
        opts[:default]
      end
    end

    module ClassMethods

      # This model should record historical values for the specified
      # attributes.
      #
      # @overload historicals(*attrs, options = {})
      #   @param [Array] attrs The symbol(s) for the attributes for which you want to store historicals
      #   @param [Hash] options
      #   @option options [Integer] :max The maximum number of entries to store (default: unlimited)
      #   @option options [:monthly,:weekly,:daily] :frequency The frequency to use for DateTime labels (default: :daily)
      def historicals(*attrs)
        options = attrs.extract_options!
        options[:max] ||= nil
        options[:frequency] ||= :daily

        self.historical_options = options
        self.historical_attributes = attrs
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
  end
end
