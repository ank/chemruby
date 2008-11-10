#!/usr/local/bin/ruby

molconn = open(ARGV.shift, "r")
molconn.readline
molconn.readline
while !molconn.eof?
  line = molconn.readline
  if /-1/ !~ line
    num, code, element, *connection = line.split(',')
    puts connection.join(' ')
  end
end
