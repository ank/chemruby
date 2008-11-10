# Author::     Nobuya Tanaka t@chemruby.org

module Chem

  # A module for assigning canonical smiles
  module Molecule#CanonicalSmiles
    require 'chem/data/periodic_table'
    require 'chem/data/prime_numbers'

    # Returns Canonical SMILES
    def to_cansmi
      cycle = 0
      priority = canonical_smiles_priority_from_invariant
      new_priority, n = update_priority(priority)
#      show new_priority
      prev_n = 0
      while prev_n != n
        prev_n = n
        new_priority = calc_prime_product(new_priority)
#        show new_priority
        new_priority, n = update_priority(new_priority)
#        show new_priority
      end

      puts
      for node in @nodes
        p new_priority[node]
      end
      show new_priority
      start = new_priority.min{|a, b| a[1] <=> b[1]}[0]
      get_tree(start, new_priority)
#      get_canonical_smiles start, new_priority
    end

    private
    def get_tree start, priority
      traversed = []
      traversed_atom = []
      rings = {}
      ring_to = {}
      n = 1
      cc = cansmi_dfs([nil, start], traversed_atom, traversed, priority, rings)
      p cc
      cansmi_to_s cc, rings, ring_to, n
    end

    private
    def cansmi_to_s cc, rings, ring_to, n
      str = ''
      while cc and cc.length > 0
        if cc.last.instance_of?(Array)
          c = cc.pop
          while c.length > 1
            str += '('
            str += cansmi_to_s(c.pop, rings, ring_to, n)
            str += ')'
          end
          str += cansmi_to_s(c.pop, rings, ring_to, n)
        else
          atom = cc.pop
          str += atom.respond_to?(:element) ? atom.element.to_s : atom
          if ring_to[atom]
            for r in ring_to[atom]
              str += r.to_s
            end
          end
          if rings[atom]
            for from in rings[atom]
              str += n.to_s
              (ring_to[from] ||=[]).push n
              n += 1
            end
          end
        end
      end
      str
    end

    private
    def cansmi_dfs from, traversed_atom, traversed, priority, rings
      frag = []
      adjacent_to(from[1]).sort{|a, b|
        if a[0].v == b[0].v
          print " * "
          p priority[b[1]]
          print "=* "
          p priority[a[1]]
          p priority[b[1]] <=> priority[a[1]]
          priority[a[1]] <=> priority[b[1]]
        else
          b[0].v <=> a[0].v
        end
      }.each do |bond, atom|
        next if traversed.include?(bond)
        traversed << bond
        if traversed_atom.include?(atom)
          print "ring!"
          (rings[atom] ||= []) << from[1]
        else
          print "#"
          p priority[atom]
          traversed_atom << from[1]
          frag << cansmi_dfs([bond, atom], traversed_atom, traversed, priority, rings)
        end
      end
      case frag.length
      when 0
        case from[0].v
        when 2
          frag = [from[1], "="]
        when 3
          frag = [from[1], "#"]
        else
          frag = [from[1]]
        end
      when 1
        frag = frag[0]
        if from[0]
          case from[0].v
          when 2
            frag.concat [from[1], "="]
          when 3
            frag.concat [from[1], "#"]
          else
            frag << from[1]
          end
        else
          if from[0]
            case from[0].v
            when 2
              frag.concat [from[1], "="]
            else
              frag << from[1]
            end
          else
            frag << from[1]
          end
        end
#        frag << from[1]
      else
        if from[0]
          case from[0].v
          when 2
            frag = [frag.reverse, from[1], "="]
          else
            frag = [frag.reverse, from[1]]
          end
        else
          frag = [frag.reverse, from[1]]
        end
      end
      frag
    end

    private
    def show pri
      @nodes.each do |node|
        print "%5d" % pri[node].last
      end
      puts
    end

    private
    def calc_prime_product priority
      res = priority.keys.inject({}) do |r, node|
        product = self.adjacent_to(node).inject(1) do |result, adj|
          result * priority[adj[1]].last
        end
        r[node] = product
        r
      end
      res.each do |k, v|
        priority[k] << v
      end
      priority
    end

    private
    def update_priority priority
      i = 0
      prev = nil
      new_priority = {}
      priority.sort_by{|k, v| v}.each do |k, v|
        i += 1 if prev != v
        new_priority[k] = PrimeNumber[i - 1]
        prev = v
      end
      new_priority.each do |k, v|
        priority[k] << v
      end
      [priority, i]
    end

    # (1) number of connections
    # (2) number of non-hydrogen bonds
    # (3) atomic number
    # (4) sign of charge
    # (5) absoluete charge
    # (6) number of attached hydrogens
    private
    def canonical_smiles_priority_from_invariant
      priority = {}
      @nodes.each do |node|
        n_connection  = self.adjacent_to(node).inject(0) do |result, ary|
          result + ary[0].v if ary[1].element != :H
        end

        n_non_hydrogen_bonds = self.adjacent_to(node).inject(0) do |result, ary|
          result + 1 if ary[1].element != :H
        end

        atomic_number = node.atomic_number
        
        priority[node] = [
          n_connection,
          n_non_hydrogen_bonds,
          atomic_number]
        p priority[node]
      end
      priority
    end

  end
end


if $0 == __FILE__
  
  require 'chem'

  mol = Chem.parse_smiles("OCC(CC)CCC(CN)CN")
  mol.extend(Chem::CanonicalSmiles)
  mol.canonical_smiles
end
