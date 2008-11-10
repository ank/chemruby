#!/usr/local/bin/ruby

require 'matrix'

module Chem

  module Transform

    module TwoDimension

#      attr_reader :pos
#       def initialize
#         super
#         @pos = Vector[0.0, 0.0]
#       end

      def pos ; @pos ||= Vector[@x, @y, @z] ; end
      def x ; pos[0] ; end
      def y ; pos[1] ; end
      def x=(x_val) ; pos[0] = x_val ; end
      def y=(y_val) ; pos[1] = y_val ; end
    end

    module ThreeDimension
      include TwoDimension
      
#       def initialize
#         super
#         @pos = Vector[0.0, 0.0]
#       end

      def z ; pos[2] ; end
      def z=(z_val) ; pos[2] = z_val ; end

    end

  end
end

class Transform

  def initialize m = Matrix.new
    @m = m
  end

  def * (t)
    @m * t
  end

  def transform(v)
    v * @m
  end

  def Transform::translate(x, y, z)
    Matrix[[1, 0, 0, 0],
           [0, 1, 0, 0],
           [0, 0, 1, 0],
           [x, y, z, 1]].transpose
  end

  def Transform::scale(x, y, z)
    Matrix[[x, 0, 0, 0],
           [0, y, 0, 0],
           [0, 0, z, 0],
           [0, 0, 0, 1]].transpose
  end

  def Transform::rotate_x(theta)
    Matrix[[1.0,               0.0,             0.0, 0.0],
           [0.0,   Math.cos(theta), Math.sin(theta), 0.0],
           [0.0, - Math.sin(theta), Math.cos(theta), 0.0],
           [0.0,               0.0,             0.0, 1.0]].transpose
  end

  def Transform::rotate_y(theta)
    Matrix[[Math.cos(theta),   0.0, - Math.sin(theta), 0.0],
           [0.0,               1.0,               0.0, 0.0],
           [Math.sin(theta),   0.0,   Math.cos(theta), 0.0],
           [0.0,               0.0,               0.0, 1.0]].transpose
  end

  def Transform::rotate_z(theta)
    Matrix[[  Math.cos(theta),   Math.sin(theta),   0.0, 0.0],
           [- Math.sin(theta),   Math.cos(theta),   0.0, 0.0],
           [  0.0,               0.0,               1.0, 0.0],
           [  0.0,               0.0,               0.0, 1.0]].transpose
  end

  def Transform::inverse_x
    Matrix[[ -1,  0,  0,  0],
           [  0,  1,  0,  0],
           [  0,  0, -1,  0],
           [  0,  0,  0,  1]].transpose
  end

  def Transform::inverse_y
    Matrix[[  1,  0,  0,  0],
           [  0, -1,  0,  0],
           [  0,  0,  1,  0],
           [  0,  0,  0,  1]].transpose
  end

  def Transform::inverse_z
    Matrix[[  1,  0,  0,  0],
           [  0,  1,  0,  0],
           [  0,  0, -1,  0],
           [  0,  0,  0,  1]].transpose
  end

end

