#!/usr/local/bin/ruby

require 'ming/ming'
require 'molfile_reader'
require 'transform'

include Ming

module Chem

  # Flash SWF writer
  # Obsolete
  class SWFWriter

    def initialize mol
      @m = SWFMovie.new
      @m.set_rate(5.0)
      @m.set_dimension(1000, 1000)
      @m.set_background(0xff, 0xff, 0xff)
      #    @m.add(make_atom(mol))
      0.upto(200) do |n|
        rotate(Math::PI * 0.01 * n, mol)
      end
    end

    def rotate n, mol
      t = Transform.translate(500.0, 500.0, 0) * Transform.scale(100, 100, 10) *
        Transform.rotate_z(n) * Transform.rotate_x(n)
      mol.transform(t)
      ib = @m.add(make_bond(mol))
      #    ia = @m.add(make_atom(mol))
      @m.next_frame
      @m.remove(ib)
      #    @m.remove(ia)
    end

    def make_atom mol
      a = SWFText.new
      f = SWFFont.new("EfontSerifB.fdb")
      a.set_font(f)
      a.set_color(0x00, 0x80, 0x40)
      height = 28
      a.set_height(height * 2)
      mol.atoms.each do |atom|
        a.move_to(atom.pos[0] - height, atom.pos[1] + height)
        a.add_string(atom.element)
      end
      a
    end

    def make_bond mol
      s = SWFShape.new
      mol.bonds.each do |bond|

        s.set_line(1, 0x0, 0, 0)
        s.move_pen_to(bond.b.pos[0], bond.b.pos[1])
        s.draw_line_to(bond.e.pos[0], bond.e.pos[1])
      end
      s
    end

    def save fn
      @m.save(fn)
    end

  end

end

if __FILE__ == $0
  s = SWFWriter.new(MolfileReader.new(open('mol1.mol', 'r')).parse_mol)
  s.save('anim.swf')
  puts 'Created!'
end
