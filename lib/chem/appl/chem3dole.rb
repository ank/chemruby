#!/usr/bin/ruby

require 'win32ole'
controle = WIN32OLE.new('Chem3D.Control')
application = WIN32OLE.new('Chem3D.Application')
documents = application.documents
#cd = WIN32OLE.new('ChemDraw.Application')
#bounds = WIN32OLE.new('Chem3D.Bounds')

#documents.application.visible = true

error = open("error.txt", "w")

Dir.glob('/home/nobuya/src/mol/mol/C*.mol').each do |file|
  /(C\d+).mol/ =~ file
  input = 'c:\\cygwin\\home\\nobuya\\src\\mol\\mol\\' + $1 + '.mol'
  output = 'c:\\cygwin\\home\\nobuya\\mop\\' + $1 + '.mop'

  puts input
  document = documents.open(input)
  if document
    document.saveAs(output)
    document.close
  else
    error.puts(input)
  end
end

__END__
p document = documents.open('c:\cygwin\home\nobuya\src\mol\mol\C00001.mol')
p documents.Item(0)
p document.stericEnergy
document.saveAs('c:\cygwin\home\nobuya\xyz\C00001.xyz')



