
module Stone
  module AST
    TRUE=1
    FALSE=0

    class Node

      def eval(env)
        raise StoneError.new("cannot eval #{self}",self)
      end

    end

    # class Leaf < Node
    
    # end

    # class List < Node

    # end

    class NumLiteral < Leaf

      def eval(env) = value
    
    end

    class StrLiteral < Leaf

      def eval(env) = value
    
    end

    class Name < Leaf

      def eval(env)
        val=env.get(name)
        raise StoneError.new("undefined name: #{name}",self) if val.nil?
        val
      end
   
    end

    class NegExpr < List

      def eval(env)
        val=operand&.eval env
        raise StoneError.new("bad type for -",self) unless val.is_a? Integer
        -val
      end
    
    end

    class BinExpr < List

      def eval(env)
        op=operator
        # Object | nil cant be Object?
        rval=right&.eval env
        if op.eql? "="
          # make steep happy
          #@type var rval:Object
          # p [left&.name,op,rval]
          do_assign env,rval
        else
          lval=left&.eval env 
          #@type var rval:Object
          # p [lval,op,rval]
          do_op lval,op,rval
        end
      end

      def do_assign(env,rval)
        l=left
        raise StoneError.new("bad assignment",self) unless l.is_a? Name
        env.set l.name,rval
        rval
      end

      def do_op(lval,op,rval)
        if lval.is_a?(Integer) && rval.is_a?(Integer)
          num_compute lval,op,rval
        elsif op.eql? "+"
          lval.to_s + rval.to_s
        elsif op.eql? "=="
          lval.eql? rval ? TRUE : FALSE
        else
          raise StoneError.new("bad type",self)
        end
      end

      def num_compute(lval,op,rval)
        case op
        when "+","-","*","/","%"
          lval.send(op,rval)
        when "==",">","<"
          lval.send(op,rval) ? TRUE : FALSE
        else
          raise StoneError.new("bad operator",self)
        end
      end

    end

    class BlockStmnt < List

      def eval(env)
        # p :block
        self.filter_map {|node| node.eval(env) unless node.is_a?(NullStmnt)}.last || FALSE
      end

    end

    # class PrimaryExpr < List

    # end

    module EvalCondition

      def turthy?(con) = con.is_a?(Integer) && !con.eql?(FALSE)

    end

    class IfStmnt < List

      include EvalCondition

      def eval(env)
        con=condition&.eval env
        # p [:if,con]
        if turthy? con
          # p :then
          then_block&.eval(env) || FALSE
        else
          # p :else
          else_block&.eval(env) || FALSE
        end
      end

    end

    class WhileStmnt < List

      include EvalCondition

      def eval(env)
        while turthy? (con=condition&.eval env)
          # p [:while,con]
          result=body&.eval(env)
        end
        result || FALSE
      end

    end

    # class NullStmnt < List

    # end

    class DefStmnt < List

      def eval(env)
        env.set! name, Function.new(params,body,env)
        name
      end

    end

    class PrimaryExpr < List

      def operand = _=child(0) # make steep happy

      def suffix(nest) = _=child(size-nest-1) # make steep happy

      def suffix?(nest) = size-nest>1

      def eval(env) = eval_sub_expr env,0

      # def eval(env)
      #   res=operand.eval env
      #   res=self.drop(1).reverse.reduce{ |res,suffix| suffix.eval(env)} if size>1
      # end

      def eval_sub_expr(env,nest)
        if suffix? nest
          target=eval_sub_expr env,nest+1 # get function obj
          suffix(nest).eval env,target # args.eval env,func
        else
          operand.eval env
        end
      end

    end

    class Suffix < List

      def eval(env,val)
        raise StoneError.new("cannot eval #{self},#{target}",self)
      end

    end

    class Args < Suffix

      def eval env,val
        raise StoneError.new("bad function",self) unless val.is_a? Function # val should be function
        params=val.params
        raise StoneError.new("bad number of arguments",self) unless size.eql? params.size 
        new_env=val.new_env
        self.each_with_index do |arg,idx|
          params.eval(new_env,idx,arg.eval(env)) # eval args, set to new env as name in params
        end
        val.body.eval(new_env)
      end

    end

    class Params < List
      
      def eval(env,idx,val) = env.set!(name(idx),val)

    end

  end
end
