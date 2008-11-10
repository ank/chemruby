
require 'matrix'

class Vector

  def []=(i,x) ; @elements[i]=x  ;  end

  def x        ; @elements[0]    ; end
  def y        ; @elements[1]    ; end
  def z        ; @elements[2]    ; end

  def x= x_val ; @elements[0] = x_val ; end
  def y= y_val ; @elements[1] = y_val ; end
  def z= z_val ; @elements[2] = z_val ; end

end

