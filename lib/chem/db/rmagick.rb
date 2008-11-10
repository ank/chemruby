# RMagick adaptor for chem/db/vector.rb

require 'chem/db/vector'

module Chem
  class RMagickWriter

    include Writer

    # Constructor for RMagick Adaptor
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
      @canvas.stroke("rgb(%f, %f, %f)" % to_256(color))
      @canvas.line(from[0], from[1], to[0], to[1])
    end

    def fill(nodes, color, params = {})
      @canvas.stroke("rgb(%f, %f, %f)" % to_256(color))
      @canvas.fill("rgb(%f, %f, %f)" % to_256(color)) if color
      path = nodes.inject([]){|ret, node| ret << node[0] ; ret << node[1]}
      @canvas.polygon(* path)
      @canvas.fill("black")
    end

    def text(str, x, y, params = {})
      @canvas.pointsize = @default_pointsize
      metrics = @canvas.get_type_metrics(@img, str)
      @canvas.stroke('transparent')
      @canvas.pointsize(params[:pontsize])             if params[:pointsize]
      @canvas.fill("rgb(%f, %f, %f)" % to_256(params[:color])) if params[:color]

      @canvas.text(x - metrics.width / 2.0,
                   y + metrics.height / 4.0,
                   str)

      @canvas.pointsize(@default_pointsize)            if params[:pointsize]
      @canvas.fill('black')                            if params[:color]
    end

    def self.save(mol, filename, params)
      writer = self.new(mol, params)
      writer.draw(filename, params)
    end

    def draw filename, params
      @img = Magick::ImageList.new
      x, y = params[:size]
      x += params[:margin][0] * 2
      y += params[:margin][0] * 2
      @img.new_image(x, y)

      @canvas = Magick::Draw.new
      draw_body
      
      @canvas.draw(@img)
      @img.write(filename)
    end

  end
end

