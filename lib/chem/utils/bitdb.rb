#
# = chem/utils/bitdb.rb - Bit Database
#
# Author::	Toshiaki Katayama <k@bioruby.org>
#               Nobuya   Tanaka   <t@chemruby.org>
#		
# Copyright::	Copyright (c) 2005, 2006 ChemRuby project
#
# $Id: bitdb.rb 180 2006-04-19 08:52:15Z tanaka $
#


class BitDatabase

  ARCH = 32

  attr_reader :bit_length

  def initialize(filename, bit_length)
    @out = File.open(filename + ".dat", "w")
    @idx = File.open(filename + ".inf", "w")
    @bit_length = bit_length
    @n_bytes    = (bit_length - 1) / ARCH + 1
    @idx.write [@bit_length, @n_bytes].pack("l*")
    @current    = 0
  end

  def push(ary)
    @current += 1
    @out.write ary.inject(Array.new(@n_bytes, 0)){|ret, num|
      raise Exception if num > @bit_length
      ret[num / ARCH] += (1 << (num % ARCH))
      ret
    }.pack('l*')
  end

  def close
    @idx.write [@current * 1000].pack("l*")
    @idx.close
    @out.close
  end

  def self.open(filename, bit_length)
    db = new(filename, bit_length)
    yield db
    db.close
  end

end
