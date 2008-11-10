#
# Chem module.  See documentation for the file chem.rb for an overview
#
# $Id: chem.rb 160 2006-02-14 06:49:37Z tanaka $
#
# == Introduction
#
# Chem module is a facade of ChemRuby. You will find all the input format
# that ChemRuby support can be invoked via Chem module.
#
# == Examples
#
# === Example 1: Parse molecular file
#
#   require 'chem'
#
#   mol = Chem.open_mol("/usr/local/foo/mol/C00147.mol")
#
# === 


require 'stringio'
require 'graph'

require 'chem/data'
require 'chem/utils'
require 'chem/model'
require 'chem/appl'
require 'chem/db'

require 'tempfile'

# Convension over Configuration

module Chem
  # read ~/.chemrc or...
  if ENV["HOME"]
    DefaultDataDir = File.join(ENV["HOME"], "data")
  end

  def self.data_dir
    DefaultDataDir
  end

  autoload   :MDL,   'chem/db/mdl.rb'
  autoload   :CDX,   'chem/db/cdx.rb'
  autoload   :G98,   'chem/db/g98.rb'
  autoload   :GSpan, 'chem/db/gspan.rb'

  module_function

  # format_class = Chem.autodetect("file.mol")
  #
  # Automatically detect file type and returns
  # appropriate class to parse it 
  def self.autodetect file
    ChemTypeRegistry.find{|format| format.detect_file file}
  end

  # Makes possible to open chemical files.
  # Guesses the file type based on the extension of the file name.
  #
  # Examples : So if the file name is "benzene.mol",
  # 
  # mol = Chem.open_mol("benzene.mol") # returns MDLMolecule object
  #
  def open_mol file, format_type = nil
    format = nil
    if format_type == nil
      format = Chem.autodetect(file)
    else
      format = ChemTypeRegistry.find{|format| format.detect_type format_type}
    end
    raise NotImplementedError unless format
    return format.parse(file) if format
  end

  alias :parse_file :open_mol
  alias :load       :open_mol
  module_function :parse_file
  module_function :load

  # 
  def self.save(array, filename, params = {})
    format = autodetect filename
    format.save(array, filename, params)
  end

  def parse_smiles smiles
    require 'chem/db/smiles'
    require 'chem/db/smiles/smiparser'
    ::SmilesParser.parse_smiles(smiles)
  end

  def open_kegg dir
    require 'chem/db/kegg'
    Chem::KEGG::KeggDirectory.new(dir)
  end

  module Molecule

    # Saves files for arbitrary format.
    # file type is automatically detected by file extensions.
    # 
    # You can optionally pass parameters as second argument.
    # = Options
    # :type::     => :png # Explicit file type
    #
    def save(filename, params = {}, &block)

      format_type = params[:type]
      format = ChemTypeRegistry.find{|format| format.detect_type format_type}

      unless format_type
        format = ChemTypeRegistry.find{|format| format.detect_file filename}
      else
        format = ChemTypeRegistry.find{|format| format.detect_type format_type}
      end

      unless format
        raise(NotImplementedError)
      end
      format.save(self, filename, params)
    end

    # Redirect methods to OpenBabel
    def method_missing(m, *args)
      unless @ob_mol.respond_to?(m)
        super(m, *args)
      end
      @ob_mol.__send__(m, *args)
    end

  end

  module Atom
    def method_missing(m, *args)
      if not @ob_atom.nil? and @ob_atom.respond_to?(m)
        @ob_atom.__send__(m, *args)
      else
        super(m, *args)
      end
    end
  end

end

# Syntax sugar for Chem.parse_smiles("smiles_string")
# Returns molecular object.
# Example
# SMILES("C1CCCC1")
def SMILES smiles
  Chem.parse_smiles(smiles)
end

  
