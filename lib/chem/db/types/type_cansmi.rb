
module Chem
  module Molecule
    def to_cansmi
      require 'chem/db/cansmi.rb'
      self.to_cansmi
    end
  end
end
