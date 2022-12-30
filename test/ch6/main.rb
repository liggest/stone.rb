
require "stone.rb"

lexer=Stone::Lexer.new ARGF
parser=Stone::BasicParser.new
env=Stone::BaseEnv.new

#@type var file:IO?
file=nil
until lexer.peek(0).eql? Stone::Token::EOF
  if !file.eql?(ARGF.file)
    puts "File: #{ARGF.filename}"
    file=ARGF.file
  end
  ast=parser.parse lexer
  puts "=> #{ ast }"
  next if ast.is_a?(Stone::AST::NullStmnt)
  puts "=> #{ ast.eval(env) }"
end

=begin

File: ./test/ch6/example.stone
=> (even = 0)
=> 0
=> (odd = 0)
=> 0
=> (i = 1)
=> 1
=> (while (i < 10) ((if ((i % 2) == 0) ((even = (even + i))) else ((odd = (odd + i)))) (i = (i + 1))))
=> 10
=> (even + odd)
=> 45
File: ./test/ch6/sum.stone
=> (sum = 0)
=> 0
=> (i = 1)
=> 1
=> (while (i < 10) ((sum = (sum + 1)) (i = (i + 1))))
=> 10
=> sum
=> 9
File: ./test/ch6/test.stone
=> (x = (3 + ((5 * 2) * (even + odd))))
=> 453
=> 3
=> 3
=> ((3 + 5) + 2)
=> 10
=> ()
=> ()
=> ()

=end

