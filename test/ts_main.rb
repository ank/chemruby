require 'test/unit'

Dir.glob("test/tc_*").reject{|file|
  [
    "test/tc_net.rb",
    "test/tc_develop.rb"
  ].include?(file)
}.each do |test|
  require test[0..-(File.extname(test).length + 1)]
end

require 'test/tc_sssr'
