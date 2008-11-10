#
# chem/appl/tinker/nucleic.rb - Tinker/nucleic wrapper
# 
#
#  $Id: nucleic.rb 128 2006-02-03 02:53:22Z tanaka $
#

# = Chem::TINKER
# Tinker protein wrapper.
# Example : 
#   #!/usr/bin/env ruby
#   require 'chem'
#
# === SEE ALSO
# * http://dasher.wustl.edu/tinker/


module Chem

  class TinkerNucleic

    def initialize(cmd_line)
      @cmd_line = cmd_line + ' -stdout'
    end

    def exec
      begin
	@io = IO.popen(@cmd_line, "w+")
	@result = @io.read
	return @result
      ensure
	@io.close
      end
    end
    attr_reader :io, :result

  end

end

