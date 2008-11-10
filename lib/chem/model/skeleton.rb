
module Chem

  class SkeletonAtom
    include Atom
    attr_accessor :x, :y, :z
  end

  class ReactionSkeleton

    include Reaction

    def initialize compounds
      @compounds = []
      @compounds[0] = get_compounds(compounds[0])
      @compounds[1] = get_compounds(compounds[1])
    end

    def compounds
      @compounds
    end

    private
    def get_compounds(comp)
      ret = {}
      comp.each do |c|
        if c.kind_of?(Array)
          ret[c[0]] = c[1]
        else
          ret[c] = 1
        end
      end
      ret
    end

  end
end
