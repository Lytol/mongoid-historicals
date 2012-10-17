module Mongoid
  module Historicals
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps::Created

    end
  end
end
