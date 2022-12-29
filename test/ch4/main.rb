
require "stone.rb"

lexer=Stone::Lexer.new ARGF
parser=Stone::BasicParser.new

# node=parser.parse lexer
# p node
# puts "=> #{ node }"

until lexer.peek(0).eql? Stone::Token::EOF
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

