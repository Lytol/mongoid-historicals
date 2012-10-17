module Mongoid
  module Historicals
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps::Created

      field :'_label', type: String
    end
  end
end
