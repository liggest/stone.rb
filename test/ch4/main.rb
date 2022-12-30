
require "stone.rb"

lexer=Stone::Lexer.new ARGF
parser=Stone::BasicParser.new

# node=parser.parse lexer
# p node
# puts "=> #{ node }"

#@type var file:IO?
file=nil
until lexer.peek(0).eql? Stone::Token::EOF
  if !file.eql?(ARGF.file)
    puts "File: #{ARGF.filename}"
    file=ARGF.file
  end
  # p token
  puts "=> #{ parser.parse lexer }"
end

=begin

=> (even = 0)
=> (odd = 0)
=> (i = 1)
=> (while (i < 10) ((if ((i % 2) == 0) ((even = (even + i))) else ((odd = (odd + i)))) (i = (i + 1))))
=> (even + odd)

=end

