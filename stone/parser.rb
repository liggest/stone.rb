require "set"

module Stone
  class Parser
    
    attr_reader :elements,:factory

    def initialize(obj)
      if obj.nil? || (obj.is_a?(Class) && obj < AST::Node)
        # @type var obj:singleton(AST::Node)?
        reset(obj)
      elsif obj.is_a? Parser
        @elements=obj.elements
        @factory=obj.factory
      end
    end

    def parse(lexer)
      results=[]
      elements.each do |e|
        e.parse(lexer, results)
      end
      factory.make results
    end

    def match?(lexer)
      if elements.empty?
        true
      else
        elements.first&.match? lexer
      end
    end
    
    def reset(cls=(no_arg=true; nil)) # empty parser 
      # magic
      # reset() => no_arg    reset(nil) => no_arg==nil
      @elements=[]
      @factory=Factory.get_for_ASTList cls if !no_arg # set cls of Node
      self
    end

    # inner classes

    class Element
      
      def parse(lexer,res)
        raise ParseError
      end
      
      def match?(lexer)
        raise ParseError
      end

    end

    class Tree < Element
      attr_reader :parser

      def initialize(psr)
        @parser=psr
      end

      def parse(lexer,res)
        res << parser.parse(lexer)
      end

      def match?(lexer) = parser.match?(lexer)
    end

    class OrTree < Element
      attr_reader :parsers

      def initialize(psrs)
        @parsers=psrs
      end

      def parse(lexer,res)
        prs=choose(lexer)
        raise ParseError,lexer.peek(0) if !prs
        res << prs.parse(lexer)
      end

      def match?(lexer) = choose(lexer)

      def choose(lexer) = parsers.find {|prs| prs.match?(lexer) }

      def insert(p) = parsers.prepend(p)
      
      def append(p) = parsers.append(p)
    end

    class Repeat < Element
      attr_reader :parser

      def initialize(psrs,once)
        @parser=psrs
        @once=once
      end

      def once? = @once

      def parse(lexer,res)
        while parser.match?(lexer)
          t=parser.parse(lexer)
          res << t if !t.class.eql?(AST::List) || t.size>0
          break if once?
        end
      end

      def match?(lexer) = parser.match?(lexer)
      
    end

    class AToken < Element
      attr_reader :factory

      def initialize(cls)
        cls=AST::Leaf if !cls
        @factory=Factory.get cls
      end

      def parse(lexer,res)
        t=lexer.read
        if test? t
          res << (factory.make t)
        else
          raise ParseError, t
        end
      end

      def match?(lexer) = test?(lexer.peek 0)

      def test?(token) = nil
      
    end

    class NameToken < AToken
      attr_reader :reserved

      def initialize(cls,reserve)
        super cls
        @reserved= reserve || Set.new
      end

      def test?(token) = token.is_name? && !(reserved.include? token.str)
      
    end

    class NumToken < AToken
      def test?(token) = token.is_num?
    end

    class StrToken < AToken
      def test?(token) = token.is_str?
    end

    class Leaf < Element
      attr_reader :tokens

      def initialize(pattern)
        @tokens=pattern
      end

      def parse(lexer,res)
        t=lexer.read
        if t.is_name?
          tokens.each do |st|
            return find(res,t) if st.eql? t.str # unimportant return value
          end
        end
        if tokens.empty?
          raise ParseError, t
        else
          raise ParseError.new("#{tokens[0].inspect} expected.", t)
        end
      end

      def find(res,token)
        res << AST::Leaf.new(token)
      end

      def match?(lexer)
        t=lexer.peek 0
        if t.is_name?
          return tokens.any? {|st| st.eql? t.str}
        end
      end
    end

    class Skip < Leaf
      def find(res,token) = nil
    end

    class Precedence
      attr_reader :value

      def left? = @left # left associative
      
      def initialize(val,left)
        @value=val
        @left=left
      end
      
    end

    class Operators < Hash
      LEFT=true
      RIGHT=false

      def add(name,prec,left)
        self[name]=Precedence.new prec,left
      end
    end

    class Expr < Element
      attr_reader :factory, :ops, :factor

      def initialize(cls,expr,ops_map)
        @factory=Factory.get_for_ASTList cls 
        @ops=ops_map
        @factor=expr
      end

      def parse(lexer,res)
        right=factor.parse lexer 
        while prec= next_op(lexer)
          right=do_shift lexer,right,prec.value 
        end
        res << right
      end

      def do_shift(lexer,left,prec)
        list=[left, AST::Leaf.new(lexer.read)]
        right=factor.parse lexer
        while (_next= next_op(lexer)) && right_expr?(prec,_next)
          right=do_shift(lexer,right,_next.value)
        end
        list << right
        factory.make list
      end

      def next_op(lexer)
        t=lexer.peek(0)
        ops.fetch(t.str,nil) if t.is_name?
      end

      def right_expr?(prec, next_prec)
        if next_prec.left?
          prec < next_prec.value
        else
          prec <= next_prec.value
        end
      end

      def match?(lexer) = factor.match?(lexer)

    end

    class Factory
      MethodName=:create

      def _make(arg) = nil
      
      def make(...) = _make(...)

      def self.get_for_ASTList(cls)
        f=self.get cls
        if f.nil?
          f=self.new
          #@dynamic f._make
          def f._make(arg)
            # p "list",arg
            if arg.is_a?(Array) && arg.size==1
              arg[0]
            else
              AST::List.new arg
            end
          end
        end
        return f
      end

      def self.get(cls)
        return nil if cls.nil?
        
        f=self.new
        if cls.respond_to? MethodName
          #@dynamic f._make
          f.define_singleton_method :_make do |arg|
            # p MethodName,arg
            cls.public_send MethodName,arg
          end
          # def f._make(arg)
          #   p MethodName,arg
          #   cls.public_send MethodName,arg
          # end
        else
          #@dynamic f._make
          f.define_singleton_method :_make do |arg|
            # p "new",arg
            cls.new arg
          end
          # def f._make(arg)
          #   p "new",arg
          #   cls.new arg
          # end
        end
        return f
      end
    end

    # Parser methods

    # weird
    module Rule
      def rule(cls=nil,&block)
        #@type var parser:Parser
        #@type var self:singleton(Parser)
        parser=Parser.new cls
        result=parser.instance_exec(&block) if block
        parser=result if result && result.is_a?(Parser) # make steep happy
        # parser=result if result&.is_a?(self)
        parser
      end
    end

    extend Rule

    def rule(...) = self.class.rule(...)

    def NUM(cls=nil) # NUMBER 终结符
      elements << NumToken.new(cls)
      self
    end

    def NAME(reserved,cls=nil) # NAME 终结符
      elements << NameToken.new(cls,reserved)
      self
    end

    def STR(cls=nil) # STRING 终结符
      elements << StrToken.new(cls)
      self
    end

    def token(*pattern) # token matched with pattern 终结符
      elements << Leaf.new(pattern)
      self
    end

    def sep(*pattern) # separator (unimportant part) matched with pattern 不加入 AST 中
      elements << Skip.new(pattern)
      self
    end

    def ast(parser) # add sub parser 非终结符
      elements << Tree.new(parser)
      self
    end

    def or(*parsers) # ... | ...
      elements << OrTree.new(parsers)
      self
    end

    def maybe(parser) # [ ... ] 0~1 省略时也有根节点
      parser2=Parser.new(parser)
      parser2.reset()
      elements << OrTree.new([parser,parser2])
      self
    end

    def option(parser) # [ ... ] 0~1
      elements << Repeat.new(parser,true)
      self
    end

    def repeat(parser=nil) # { ... } 0+
      result=yield if block_given?
      parser||=result
      elements << Repeat.new(parser,false) if parser
      self
    end

    def expression(sub_parser,operators,cls=nil) # BinaryExpr sub op sub
      elements << Expr.new(cls,sub_parser,operators)
      self
    end

    def insert_choice(parser) # insert ast in head or
      if (e=elements.first).is_a?(OrTree)
        e.insert(parser)
      else
        otherwise=Parser.new self
        self.reset
        self.or parser,otherwise
      end
      self
    end

    # def append_choice(parser)
    #   if (e=elements.last).is_a?(OrTree)
    #     e.append(parser)
    #   else
    #     otherwise=Parser.new self
    #     self.reset
    #     self.or parser,otherwise
    #   end
    #   self
    # end

    # alias_method :|,:append_choice
    alias_method :[],:option
  end
end
