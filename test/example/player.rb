class Player
  include Mongoid::Document
  include Mongoid::Historicals

  field :name,  type: String
  field :score, type: Float

  historicals :score
end
