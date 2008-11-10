# Encapsulated Postscript writer.

module Chem

  module Molecule
    
    EpsHeader = "%%!PS-Adobe-3.0 EPSF-3.0\n" +
      "%%Creator: ChemRuby n.tanaka\n" + 
      "%%For: Scientists\n" +
      "%%Title: Molecular compound\n" +
      "%%CreationDate: %d/%d/%d %d:%d \n"

    def to_eps(para = EpsParameter.new)
      # What should I do to ensure 2D features?

      str = ''
      if block_given?
        yield para
      end

      ratio, min = para.calc_bounding_box_size(@nodes)

      str = header(para)

      pos = {}

      @nodes.each do |atom|
        pos[atom] = Vector[atom.x, atom.y]
        pos[atom] -= min

        #diff = diff == 0 ? 1 : diff
        pos[atom] *= para.diff * 100
        pos[atom] += para.orig_pt + Vector[para.margin, para.margin] + ratio * 0.5

#         if para.has_atom_yield
#           str += eps.atom_yield.call(atom)
#         end
#        str += atom.eps_header if atom.eps_header
#        if(atom.visible)
          str += "%5f %5f moveto\n" % [pos[atom][0], pos[atom][1]]
          str += "(" + atom.element.to_s + ") dup stringwidth pop 2 div neg -1.5 rmoveto show\n"

#        end
#        str += atom.eps_footer if atom.eps_footer
      end
#      @nodes.each do ||

      @edges.each do |bond, atom1, atom2|
        #str += bond.eps_header if bond.eps_header
        beginX = pos[atom1][0]
        beginY = pos[atom1][1]
        endX   = pos[atom2][0]
        endY   = pos[atom2][1]
        dx = (endX - beginX) / ((endX - beginX)**2 + (endY - beginY)**2)**0.5
        dx = dx.nan? ? 0 : dx / 2.0
        dy = (endY - beginY) / ((endX - beginX)**2 + (endY - beginY)**2)**0.5
        dy = dy.nan? ? 0 : dy / 2.0
        if(atom2.visible)
          endX = endX - char_height * dx
          endY = endY - char_height * dy
        end
        if(atom1.visible)
          beginX = beginX + char_size * dx
          beginY = beginY + char_size * dy
        end
        transition = bond.respond_to?('i') ? bond.i : 0
        multi_bond_ratio = 1.0
        beginX = beginX - dy * (bond.v - 1 + transition.abs) * multi_bond_ratio
        beginY = beginY + dx * (bond.v - 1 + transition.abs) * multi_bond_ratio
        endX   = endX   - dy * (bond.v - 1 + transition.abs) * multi_bond_ratio
        endY   = endY   + dx * (bond.v - 1 + transition.abs) * multi_bond_ratio
        valence = bond.v
#        1.upto(bond.v + transition.abs) do |n|
        (bond.v + transition.abs).times do |n|
#           if(color)
#             if(transition < 0)
#               str += "1 0 0 setrgbcolor\n"
#             elsif(transition > 0)
#               str += "0 0 1 setrgbcolor\n"
#             else
#               str += "0 0 0 setrgbcolor\n"
#             end
#           end
          str += "newpath %f %f moveto %f %f lineto stroke\n" % [beginX, beginY, endX, endY]
          centerX = (endX + beginX) /2
          centerY = (endY + beginY) /2
                if(transition >0)
                  str += centerX.to_s + " " + centerY.to_s + " " + inbond.to_s + " 0 360 arc stroke\n"
        elsif(transition <0)
          str += "newpath %f %f moveto %f %f lineto stroke\n" %
                 [centerX + dy - dx*outbond, centerY - dx - outbond * dy,
                  centerX - dy - outbond * dx, dx - outbond * dy + centerY]
          str += "newpath %f %f moveto %f %f lineto stroke\n" %
                 [centerX + dy + dx*outbond, centerY - dx + outbond * dy, 
                  centerX - dy + outbond * dx, dy * outbond + dx + centerY]
        end
        transition = transition + 1 if(transition < 0)
        transition = transition - 1 if(transition > 0)
        valence = valence - 1
        beginX = beginX + dy  * multi_bond_ratio * 2
        beginY = beginY - dx  * multi_bond_ratio * 2
        endX   = endX   + dy  * multi_bond_ratio * 2
        endY   = endY   - dx  * multi_bond_ratio * 2
        end
      end
#      str += "0 0 0 setrgbcolor\n"
      #      str += " #{@size / 2.0} #{@size / 2.0} #{@size / 2.0 + @margin} 0 360 arc stroke\n"

      #open("test.eps", "w").puts str
      str
    end

    private 
    def header para
      now = Time.new
      str = EpsHeader % [now.day, now.month, now.year, now.hour, now.min]
#      str += "%%%%BoundingBox: %d %d %d %d\n" % [@orig_pt[0], @orig_pt[1], @orig_pt[0] + @width, @orig_pt[1] + @height]
      str += "/Arial findfont 5 scalefont setfont\n"
#      str += "#{@line_width} setlinewidth\n"
      str
    end

    class EpsParameter
      attr_accessor :width, :height, :min, :x_max, :y_max, :fit_box, :diff, :orig_pt,:margin

      def initialize
        @size = Vector[100.0, 100.0]
        @diff = 1.0
        @orig_pt = Vector[0.0, 0.0]
        @margin = 10.0
      end

      def calc_bounding_box_size nodes
        # Shocking code :P
        min = Vector[ 1.0 / 0,  1.0 / 0]
        max = Vector[-1.0 / 0, -1.0 / 0]
        nodes.each do |atom|
          min[0] = min[0] > atom.x ? atom.x : min[0]
          max[0] = max[0] < atom.x ? atom.x : max[0]
          min[1] = min[1] > atom.y ? atom.y : min[1]
          max[1] = max[1] < atom.y ? atom.y : max[1]
        end

        diff = 1.0

        ratio = Vector[1.0, 1.0]

        if @fit_box
          if ((max[0] - min[0]) / (max[1] - min[1])) >
              (@size[0]  - @margin * 2)/ (@size[1] - @margin * 2)
            diff = (@size[0] - @margin * 2) / (max[0] - min[0])
            ratio[1] = @size[1] - @margin * 2 - (max[1] - min[1]) * diff
          else
            diff = (@size[1] - @margin * 2) / (max[1] - min[1])
            ratio[0] = @size[0] - @margin * 2 - (max[0] - min[1]) * diff
          end
        end
        [ratio, min]
      end

    end

  end
end
