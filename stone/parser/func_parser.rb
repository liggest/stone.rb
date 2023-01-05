
module Stone
  class FuncParser < BasicParser

    class << self
      attr_reader :param, :params, :param_list, :args, :suffix
      attr_reader :def
    end
    
    @param=rule.NAME reserved
    # _param=@param

    @params=rule AST::Params do
      ast(param).repeat {
        rule.sep(",").ast(param)
      }
    end
    # _params=@params

    @param_list=rule do
      sep("(").maybe(params).sep(")")
    end
    # _param_list=@param_list

    # _reserved=reserved
    # _block=block
    @def=rule AST::DefStmnt do
      sep("def").NAME(reserved).ast(param_list).ast(block)
    end

    # _expr=expr
    @args=rule AST::Args do
      ast(expr).repeat {
        rule.sep(",").ast(expr)
      }
    end

    # _args=@args
    @suffix=rule do
      sep("(").maybe(args).sep(")")
    end
    
    primary.repeat { suffix }
    simple[ @args ]
    program.insert_choice self.def

    def initialize
      super
      reserved.add ")"
    end

  end

  class ClosureParser < FuncParser
    
    class << self
      attr_reader :fun
    end

    @fun=rule(AST::Fun).sep("fun").ast(param_list).ast(block)
    primary.insert_choice self.fun

  end

end
