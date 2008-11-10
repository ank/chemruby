
module Chem
  module Molecule
    # Explicitly save molecule as PDF
    # = Example:
    #   mol = Chem.open_mol("benzene.mol")
    #   mol.save_as_pdf("benzene.pdf")
    #   mol.save("benzene.pdf", :type => :pdf)
    #   mol.save("benzene.pdf") # File type will automatically detected from file extensions
    #
    def save_as_pdf(out, params = {})
      v = PDFWriter.new(self, params)
      v.save(out)
    end

    def hilight(atoms, color = [1, 0, 0])
      edges.each do |bond, atom1, atom2|
        bond.color = [1, 0, 0] if atoms.include?(atom1) and atoms.include?(atom2)
      end
      nodes.each{|atom| atom.color = [1, 0, 0] if atoms.include?(atom)}
    end

  end

  module Atom
    # position vector for visualization
    attr_accessor :v_pos
    # supplimentary information
    attr_accessor :label
  end

  module Writer

    def to_256(color)
      color.collect{|c| (c * 255).to_i}
    end

    def fbox # :nodoc:
      n = @params[:orig_point]
      m = [@params[:size][0] + n[0], @params[:size][1] + n[1]]
      line([m[0], m[1]], [m[0], n[1]], [0, 0, 0])
      line([m[0], m[1]], [n[0], m[1]], [0, 0, 0])
      line([m[0], n[1]], [n[0], n[1]], [0, 0, 0])
      line([n[0], m[1]], [n[0], n[1]], [0, 0, 0])
    end

    def draw_body # :nodoc:
      self.fbox() if @params[:fbox]
      @mol.edges.each do |bond, atom1, atom2|
        bond.color = [0, 0, 0] unless bond.color
        a1 = atom1.v_pos.dup
        a2 = atom2.v_pos.dup
        diff = a1 - a2
        len = diff.r
        # 20 % shorter
        a1 = a1 - diff * (@default_pointsize / len / 2.5) if atom1.visible
        a2 = a2 + diff * (@default_pointsize / len / 2.5) if atom2.visible

        vert = Vector[- diff[1], diff[0], 0]

        case bond.stereo
        when :up
          fill([a1, a2 + vert * 0.1, a2 - vert * 0.1], bond.color)
        when :down
          7.times do |n|
            line(a1 - diff * (1.0/ 8) * n + vert * 0.015 * n,
                 a1 - diff * (1.0/ 8) * n - vert * 0.015 * n,
                 bond.color)
          end
        else
          line(a1, a2, bond.color)
          if bond.v == 2
            v = Vector[atom1.x - atom2.x, atom1.y - atom2.y]
            @mol.adjacent_to(atom1).each do |e, node|
              next if node == atom2
              vv = Vector[atom1.x - node.x, atom1.y - node.y]
              #p a = v.inner_product(vv) / v.r / vv.r
              #p Math.acos(a)
            end
            line(a1 - vert * 0.15 - diff * 0.1,
                 a2 - vert * 0.15 + diff * 0.1,
                 bond.color)
          end
        end
      end
      @mol.nodes.each do |atom|
        params = {}
        params[:color] = atom.color if atom.color
        if atom.visible
          text(atom.label.nil? ? atom.element.to_s : atom.label, atom.v_pos[0], atom.v_pos[1], params)
        end
      end
    end

    # Constructors for Vector graphics
    # Accepts several options
    # :fbox::        true      # black line frame
    # :upside_down:: true      # turns images upside down
    # :size::        [10, 20]  # set box size
    # :pointsize::   18        # set font size
    def initialize(mol, params)
      @mol = mol
      @params = params

      unless params[:manual] == false
        mol.nodes.each do |node|
          node.visible = true unless node.element == :C
          node.x = node.x.to_f
          node.y = node.y.to_f
          node.z = node.z.to_f
        end
      end

      @params[:fbox] = true
      @min = Vector[
        mol.nodes.min{|atom1, atom2| atom1.x <=> atom2.x}.x,
        mol.nodes.min{|atom1, atom2| atom1.y <=> atom2.y}.y,
        mol.nodes.min{|atom1, atom2| atom1.z <=> atom2.z}.z
      ]
      @max = Vector[
        mol.nodes.max{|atom1, atom2| atom1.x <=> atom2.x}.x,
        mol.nodes.max{|atom1, atom2| atom1.y <=> atom2.y}.y,
        mol.nodes.max{|atom1, atom2| atom1.z <=> atom2.z}.z
      ]
      @size = @max - @min
      @size = Vector[10.0, 10.0, 0.0] if @size[0] == 0.0 or @size[0] == 0.0
      x = (@params[:size][0] - @params[:margin][0] * 2) / @size[0]
      y = (@params[:size][1] - @params[:margin][1] * 2) / @size[1]
      scale = x < y ? x : y
      margin = Vector[@params[:margin][0], @params[:margin][1], 0]
      orig = Vector[* @params[:orig_point] << 0.0]
      mol.nodes.each do |atom|
        atom.v_pos = (atom.pos - @min ) * scale + orig + margin
        if @params[:upside_down]
          atom.v_pos = Vector[
            atom.v_pos[0],
            @params[:size][1] + @params[:margin][1] + @params[:orig_point][1] - atom.v_pos[1],
            atom.v_pos[2]]
        end
      end
    end
  end
end

