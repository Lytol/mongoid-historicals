require_relative 'test_helper'

describe Mongoid::Historicals do
  describe ".historical_attributes" do
    it "should include specified attributes" do
      Player.historical_attributes.must_include :score
    end

    it "should not include other attributes" do
      Player.historical_attributes.wont_include :name
    end
  end

  describe ".historical_options" do
    it "should have default `max` of nil" do
      Player.historical_options[:max].must_equal nil
    end
  end

  describe "#record!" do
    before do
      @player = Player.create!(name: "Lytol", score: 95.0)
      @player.record!('test')
      @record = @player.historical_records.first
    end

    it "should add a historical record" do
      @player.historical_records.wont_equal []
    end

    it "should label with specified name" do
      @record._name.must_equal 'test'
    end

    it "should timestamp the record" do
      @record.created_at.wont_equal nil
    end

    it "should have existing values for specified attrbutes in record" do
      @record.score.must_equal 95.0
    end

    it "should not have values for unspecified attributes in record" do
      @record.wont_respond_to :name
    end
  end

  describe "before any recording" do
    before do
      @player = Player.create!(name: "Lytol", score: 95.0)
    end

    describe "#historical_records" do
      it "should be empty" do
        @player.historical_records.must_equal []
      end
    end
  end
end
