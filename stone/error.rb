
module Stone
  class StoneError < RuntimeError
    def initialize(msg,ast=nil)
      return super(msg) unless ast
      super("#{msg} #{ast.loc}") #TODO
    end
  end

  class ParseError < StandardError
    def location(token)
      if token.equal?(Token::EOF)
        "the last line"
      else
        %Q("#{token.str}" at line #{token.line_no})
      end
    end

    def initialize(obj,token=nil)
      if obj.is_a? Token
        token=obj
        obj=""
      end
      if token
        msg=obj
        super("syntax error around #{location(token)}. #{msg}")
      else
        super(obj)
      end
    end
  end
end
