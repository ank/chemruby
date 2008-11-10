
#require 'chem/db/smiles'
require 'chem/db/pubchem'
require 'chem/utils/openbabel'
require 'chem/utils/cdk'
require 'chem/db/opsin'
require 'chem/db/cml'


module Chem

  ChemTypeRegistry = []

  module Db
    module_function


    # Load type files
    # User would not call this method
    def load # :nodoc
      $LOAD_PATH.each do |path|
        dir = File.join(path, 'chem/db/types')
        next unless File.directory?(dir)
        Dir.entries(dir).each do |entry|
          if File.extname(entry) == ".rb" and not /^_/.match(entry)
            begin
              require(File.join(dir, entry))
            rescue LoadError => e
            end
          end
        end
      end
    end

  end

end

require 'chem/db/vector'

Chem::Db::load

__END__
# Following script is obsolete
# auto.rb is maintained manually
#
# if $0 == __FILE__
#   $: << ".."
#   $: << "../../ext"
#   require 'chem'
#   require 'find'

#   open("db/auto.rb", "w") do |out|

#     out.puts "["
#     puts "List all classes that require autoload"
#     Find.find("db/") do |file|
#       Find.prune if /\.svn/.match(file) or /~/.match(file) or /\.ry/.match(file)
#       next if File.directory?(file)
#       open(file) do |input|
#         input.each do |line|
#           if m = / class +([^ ]+)/.match(line)
#             out.puts "  [:%-30s , 'chem/%s']," % [m[1].chop, file.strip]
#           end
#         end
#       end
#     end
#     out.puts "].each do |mod, file|"
#     out.puts "  Chem.autoload mod, file"
#     out.puts "end"
#   end
# end
