require 'chem/utils/math'
require 'chem/utils/fingerprint'
require 'chem/utils/transform'
require 'chem/utils/sssr'
require 'chem/utils/traverse'
require 'chem/utils/sub'
require 'chem/utils/bitdb'

require 'chem/utils/prop'
require 'chem/utils/geometry'
require 'chem/utils/cas'
require 'chem/utils/once'

require 'chem/utils/net'

require 'chem/utils/ullmann'


module Chem
  module Molecule
    def remove_hydrogens!
      hyd = nodes.select{|atom| atom.element == :H}
      @edges = @edges.reject{|b, f, t| hyd.include?(f) or hyd.include?(t)}
      @nodes = @nodes - hyd
    end
  end
end
