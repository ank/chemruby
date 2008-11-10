require 'set'

class Integer

  def to_bit_positions
    ary = []
    i   = 0
    pow = 0
    while pow <= self
      pow = 1 << i
      if((pow & self) != 0)
        ary << i
      end
      i += 1
    end
    ary
  end

end


module Chem

  module Atom
    attr_accessor :rings
  end

  module Molecule

    def f_dfs node, path, max, &block
      if not path.length > max
        yield path
        self.adjacent_to(node).each do |bond, n|
          next if n.element == :H
          if not path.include?(n)
            path.push(n)
            f_dfs(n, path, max, &block)
            path.pop
          end
        end
      end
    end

#     ELEMNUM = {
#       :C => 0,
#       :N => 1,
#       :O => 2,
#       :P => 4}
#     ELEMNUM.default = 32

    ELEMNUM = Element2Number.inject({}) do |ret, (elem, num)|
      ret[elem] = 1 << num
      ret
    end
    ELEMNUM.default = 32

    # 
    def fingerprint(max = 3, n_bits = 32)

      find_sssr.each do |rings|
        len = rings.length
        rings.each do |atom|
          (atom.rings ||= []) << len
        end
      end

      fp = 0
      set = Set.new

      nodes.each do |node|
        f_dfs(node, [node], max) do |path|
          # Exclude unwanted path
          key = path.collect{|atom| atom.element.to_s}.join(".")
          next if set.include?(key)

          set.add(key)
          set.add(path.reverse.collect{|atom| atom.element.to_s}.join("."))
          # seed calculation
          seed = 0
          path.each_with_index do |atom, idx|
            seed += (1 << ( 5 * idx)) *
              ELEMNUM[atom.element] *
              (atom.rings.nil? ? 1 : (1 << atom.rings.length))
          end
          srand(seed)
          1.times do |n|
            fp |= 1 << rand(n_bits)
          end
        end
      end
      fp
    end

  end

end


