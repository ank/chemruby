
$: << "/home/tanaka/proj/chemruby/lib/"
$: << "/home/tanaka/proj/chemruby/ext/"

require 'chem'

# Load 
puts "Load molecules"

mols = []

Dir.glob("mol/*.mol") do |file
  mols.push Chem.open_mol(filename) if File.exist?(filename)
  print "."
end

puts
puts "Load completed!"

# Calculate with gSpan

filename = "temp/temp.gspan.#{Process.pid}.0"
filename.succ! while File.exist?(filename)
# KADOWAKi suggested to removed .fp extension
#filename = filename + ".fp"
Chem.save(mols, filename)

system("gSpan #{filename} -o -s32")
freqs = Chem.open_mol("#{filename}.fp")

# Save Image

puts
puts "Now save images in temp/"


mols.each_with_index do |mol, i|
  m = mol.match_by_ullmann(freqs[10])
  if m
    m.each do |index|
      mol.nodes[index].visible = true
    end
    # need rmagick or use pdf
    mol.save(File.join("temp", "mol_#{i}.png"))
  end
end
