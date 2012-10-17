module Mongoid
  module Historicals
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps::Created

      embedded_in :recordable, inverse_of: :historicals

      field :'_label', type: String
    end
  end
end
