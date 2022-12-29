require "set"

module Stone
  class BasicParser

    extend Parser::Rule

    reserved=Set.new
    operators=Parser::Operators.new

    _expr=rule

    # primary=rule AST::PrimaryExpr do
    #   rule.sep("(").ast(_expr).sep(")") |
    #   rule.NUM(AST::NumLiteral) |
    #   rule.NAME(reserved,AST::Name) |
    #   rule.STR(AST::StrLiteral)
    # end

    primary=rule(AST::PrimaryExpr).or(
      rule.sep("(").ast(_expr).sep(")"),
      rule.NUM(AST::NumLiteral),
      rule.NAME(reserved,AST::Name),
      rule.STR(AST::StrLiteral)
    )

    # factor=rule(AST::NegExpr).sep("-").ast(primary) | primary
    factor=rule.or(
      rule(AST::NegExpr).sep("-").ast(primary),
      primary
    )

    expr=_expr.expression(factor, operators, AST::BinExpr)

    _statement=rule
    block=rule AST::BlockStmnt do 
      sep("{") [ _statement ].repeat {
        rule.sep(";",Token::EOL) [ _statement ]
      }.sep("}")
    end
    # _block=rule AST::BlockStmnt

    simple=rule(AST::PrimaryExpr).ast(expr)

    _if_statement=rule AST::IfStmnt do
      sep("if").ast(expr).ast(block) [  
        rule.sep("else").ast(block)
      ]
    end
    _while_statement=rule AST::WhileStmnt do
      sep("while").ast(expr).ast(block)
    end

    statement=_statement.or(
      _if_statement,
      _while_statement,
      simple
    )

    # statement= _if_statement | _while_statement | simple

    # block=_block.sep("{") [ statement ].repeat {
    #   rule.sep(";",Token::EOL) [ statement ]
    # }.sep("}")

    # program=statement | rule(AST::NullStmnt).sep(";",Token::EOL)
    program=rule.or(statement,rule(AST::NullStmnt)).sep(";",Token::EOL)
    # pp program.elements
    #@dynamic initialize
    define_method :initialize do
      reserved.add ";"
      reserved.add "}"
      reserved.add Token::EOL

      operators.add "=" ,1,Parser::Operators::RIGHT
      operators.add "==",2,Parser::Operators::LEFT
      operators.add ">" ,2,Parser::Operators::LEFT
      operators.add "<" ,2,Parser::Operators::LEFT
      operators.add "+" ,3,Parser::Operators::LEFT
      operators.add "-" ,3,Parser::Operators::LEFT
      operators.add "*" ,4,Parser::Operators::LEFT
      operators.add "/" ,4,Parser::Operators::LEFT
      operators.add "%" ,4,Parser::Operators::LEFT
    end

    #@dynamic parse
    define_method :parse do |lexer|
      program.parse(lexer= _ = lexer) # make steep happy
    end

  end
end

# require "pp"
