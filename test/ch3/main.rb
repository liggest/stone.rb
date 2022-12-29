
require "stone.rb"

lexer=Stone::Lexer.new ARGF

until (token=lexer.read).eql? Stone::Token::EOF
  # p token
  puts "=> #{token.str}"
end
