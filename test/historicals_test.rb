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

    it "should have a default `frequency` of :daily" do
      Player.historical_options[:frequency].must_equal :daily
    end
  end

  describe "#record!" do
    before do
      @player = Player.create!(name: "Lytol", score: 95.0)
      @record = @player.record!('test')
    end

    it "should add a record to historicals" do
      @player.historicals.wont_equal []
    end

    it "should label with specified label" do
      @record._label.must_equal 'test'
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

    describe "when labelled record already exists" do
      it "should overwrite existing record"
    end

    describe "when `max` records is exceeded" do
      before do
        @player.class.historical_options[:max] = 5
        5.times do |i|
          @player.record!(i.to_s)
        end
      end

      after do
        @player.class.historical_options[:max] = nil
      end

      it "should delete the oldest records" do
        oldest_record = @player.historicals.desc(:created_at).last
        @player.record!('test')
        @player.historicals.wont_include oldest_record
      end
    end

    describe "when labelled with DateTime" do
      before do
        @player.update_attribute(:score, 54.0)
        @player.record!(5.days.ago)
        @player.update_attribute(:score, 65.0)
      end

      it "should be retrievable with DateTime" do
        record = @player.historical(5.days.ago)
        record.score.must_equal 54.0
      end
    end
  end

  describe "#historical" do
    before do
      @player = Player.create!(name: "Lytol", score: 95.0)
      @player.record!('test')
    end

    describe "when record exists" do
      it "should return record" do
        @record = @player.historical('test')
        @record.must_be_instance_of(Mongoid::Historicals::Record)
        @record._label.must_equal 'test'
      end
    end

    describe "when record does not exist" do
      it "should return nil" do
        @record = @player.historical('unknown-label')
        @record.must_equal nil
      end
    end
  end

  describe "#historicals" do
    before do
      @player = Player.create!(name: "Lytol", score: 95.0)
    end

    describe "before any recording" do
      it "should be empty" do
        @player.historicals.must_equal []
      end
    end
  end

  describe "#historical_difference" do
    describe "when there is no historical value" do
      before do
        @player = Player.create!(name: "Lytol", score: nil)
        @player.record!('test')
        @player.update_attribute(:score, 92.0)
      end

      it "should return 0" do
        @player.historical_difference(:score, 'test').must_equal 0
      end

      describe "and a default is provided" do
        it "should return specified `default`" do
          @player.historical_difference(:score, 'test', default: 'none').must_equal 'none'
        end
      end
    end

    describe "when there is no labeled record" do
      before do
        @player = Player.create!(name: "Lytol", score: 90.0)
        @player.record!('test')
        @player.update_attribute(:score, 92.0)
      end

      it "should return 0" do
          @player.historical_difference(:score, 'invalid').must_equal 0
      end

      describe "and a default is provided" do
        it "should return specified `default`" do
          @player.historical_difference(:score, 'invalid', default: 'none').must_equal 'none'
        end
      end
    end
  end
end
