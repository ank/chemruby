#
# module for calculating properties
#

module Chem

  module Atom

    # Returns electro negativity
    # see chem/data/electronegativity.rb
    def electro_negativity
      ElectroNegativity[self.element]
    end

    # Returns Natural Bond Order of this atom
    # :C => 4, :H => 1...
    # see chem/data/character.rb
    def natural_bond_order
      NaturalBondOrder[self.element]
    end

    # Returns Atomic weight
    # see chem/data/atomic_weight.rb
    def weight
      AtomicWeight[self.element]
    end

  end

  module Molecule

    # Returns number of hydrogen
    # this method may be overrided
    def n_hydrogen node
      n_h = node.natural_bond_order
      adjacent_to(node).each do |bond, atom|
        n_h -= bond.v
      end
      n_h
    end

    # Returns molecular weight
    # mol.molecular_weight :unknown_atom => true
    def molecular_weight prop = {}
      comp = self.composition()
      comp.inject(0.0){|ret, (el, n)|
        if AtomicWeight[el]
          ret + AtomicWeight[el] * n
        elsif prop[:neglect_unknown_atom]
          ret
        else
          return nil
        end
      }
    end

    alias mw molecular_weight

    # Returns oxidation number of node
    # this method can be moved to Atom module
    def oxidation_number node
      en = 0
      adjacent_to(node).each do |bond, atom|
        case node.electro_negativity <=> atom.electro_negativity
        when -1
          en += bond.v
        when 1
          en -= bond.v
        end
      end
      # implicit hydrogen
      if ElectroNegativity[:H] < node.electro_negativity
        en -= n_hydrogen(node)
      else
        en += n_hydrogen(node)
      end
      en
    end

    # Returns composition
    # Chem.open_mol("benzene").composition # {:C => 6, :H => 6}
    def composition

      composition = {}
      @nodes.each do |atom|
        composition[atom.element] ||= 0
        composition[atom.element] += 1
      end
      composition
    end

    # return     1 if self.composition >  to.composition
    # return     0 if self.composition == to.composition
    # return    -1 if self.composition <  to.composition
    # return false if self.composition <> to.composition
    def subset_in_composition?(to)
      self_is_sub = false
      to_is_sub   = false
      all = (to.composition.keys + composition.keys).uniq
      return false if all.length == 0
      if (all - composition.keys).length > 0 && (all - to.composition.keys).length > 0
        return false
      elsif (all - composition.keys).length > 0
        return -1 if composition.all?{|k, v| v <= to.composition[k]}
        return false
      elsif (all - to.composition.keys).length > 0
        return 1 if to.composition.all?{|k, v| v <= composition[k]}
        return false
      elsif all.length == composition.keys.length && all.length == to.composition.length
        # then compare number of nodes ?
        if all.all? { |node| composition[node] == to.composition[node]}
          return 0
        elsif all.all?{ |node| composition[node] >= to.composition[node]}
          return 1
        elsif all.all?{ |node| composition[node] <= to.composition[node]}
          return -1
        end
      end
      return false
    end

  end
end
