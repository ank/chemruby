# RMagick adaptor for chem/db/vector.rb

require 'chem/db/vector'

module Chem
  class GDWriter

    include Writer

    # Constructor for GD Adaptor
    # See chem/db/vector.rb for detail parameters
    def initialize mol, params
      params[:size]        ||= [350, 350]
      params[:orig_point]  ||= [10, 10]
      params[:margin]      ||= [10, 10]
      @default_pointsize = (params[:pointsize] ? params[:pointsize] : 14)
      params[:upside_down] = params[:upside_down] ? false : true
      super
    end

    # Draws line
    # This method may be invoked from chem/db/vector.rb
    def line(from, to, color)
      a_color = @img.colorAllocate(*to_256(color))
      @img.line(from[0], from[1], to[0], to[1], a_color)
    end

    def self.save(mol, filename, params)
      writer = self.new(mol, params)
      writer.draw(filename, params)
    end

    def fill(nodes, color, params = {})
      poly = GD::Polygon.new
      nodes.each do |node|
        poly.addPt(node[0], node[1])
      end
      @img.filledPolygon(poly, @img.colorAllocate(*to_256(color)))
    end

    def text(str, x, y, params = {})
      font = GD::Font::LargeFont
      a_color = nil
      a_color = params[:color] ? @img.colorAllocate(*to_256(params[:color])) : @img.colorAllocate(0, 0, 0)
      @img.string(font, x - font.width / 2.0, y - font.height / 2.0, str, a_color)
    end
    
    def draw filename, params

      x, y = params[:size]
      x += params[:margin][0] * 2
      y += params[:margin][0] * 2
      
      @img = GD::Image.new(x, y)
      background_color = @img.colorAllocate(255, 255, 255)

      # Vector#draw_body
      draw_body
      
      @img.png(open(filename, "w"))
    end

  end
end
