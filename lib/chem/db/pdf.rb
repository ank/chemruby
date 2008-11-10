
require 'chem/db/vector'

module Chem
  class PDFWriter

    include Writer

    PDFHeader = <<EOL
%PDF-1.3
1 0 obj
<< /Type /Catalog
/Outlines 2 0 R
/Pages 3 0 R
>>
endobj
2 0 obj
<< /Type /Outlines
/Count 0
>>
endobj
3 0 obj
<< /Type /Pages
/Kids [ 4 0 R]
/Count 1
>>
endobj
4 0 obj
<< /Type /Page
/Parent 3 0 R
EOL

    PDFMiddle = <<EOL
/Contents 5 0 R
/Resources << /ProcSet 6 0 R
/Font << /F1 7 0 R >>
>>
>>
endobj
5 0 obj
EOL

    PDFFooter = <<EOL
endstream
endobj
6 0 obj
[ /PDF /Text ]
endobj
7 0 obj
<< /Type /Font
/Subtype /Type1
/Name /F1
/BaseFont /Helvetica
/Encoding /MacRomanEncoding
>>
endobj
xref
0 8
0000000000 65535 f
0000000009 00000 n
0000000074 00000 n
0000000120 00000 n
0000000179 00000 n
0000000364 00000 n
0000000466 00000 n
0000000496 00000 n
trailer
<< /Size 8
/Root 1 0 R
>>
startxref
625
%%EOF
EOL

    def initialize mol, params
      params[:size]        ||= [180, 200]
      params[:orig_point]  ||= [0, 0]
      params[:margin]      ||= [10, 10]
      @default_pointsize = (params[:pointsize] ? params[:pointsize] : 14)
      super
    end

    def line(from, to, color)
      @vect << color.join(' ') + " RG"
      @vect << "#{from[0]} #{from[1]} m"
      @vect << "#{to[0]} #{to[1]} l"
      @vect << "S"
    end

    def fill(nodes, color)
      @vect << "0 w"                       # setline width
      @vect << color.join(' ') + " RG"     # set setrgbcolor
      @vect << "%d %d m" % [nodes[0][0], nodes[0][1]]
      nodes[1..-1].each do |vect|
        @vect << "%d %d l" % [vect[0], vect[1]]
      end
      @vect << "b"
      @vect << "1 w"                       # setline width
    end

    def text(str, x, y, params = {})
      @vect << "BT"
      color = params[:color].nil? ? "0 0 0" : params[:color].join(" ")
      @vect << "#{color} rg"
      @vect << "/F1 #{@params[:font]} Tf"
      @vect << "1 0 0 1 #{x - @params[:font] * 0.4} #{y - @params[:font] * 0.4} Tm"
      @vect << "(#{str}) Tj"
      @vect << "ET"
    end

    def save out
      @out = out
      @params[:font] ||= 12.0
      @params[:orig_point] ||= [0, 0]
      @vect = ["q"]
      @vect << "1 0 0 1 #{@params[:orig_point][0]} #{@params[:orig_point][1]} cm"
      @out.puts(PDFHeader)
      @out.puts "/MediaBox [ 0 0 %d %d]" % @params[:size]
      @out.puts PDFMiddle

      draw_body

      @vect << "Q"
      str = @vect.join("\n")

      @out.puts "<< /Length #{str.length} >> stream"
      @out.puts str
      @out.puts PDFFooter
    end

  end
end
