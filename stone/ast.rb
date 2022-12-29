

module Stone
  module AST
    class Node
      include Enumerable

      Empty=[]

      def child(i) = nil

      def size = 0

      def children = Empty.to_enum

      def location = nil

      alias_method :each, :children

    end

    class Leaf < Node

      attr_reader :token

      def initialize(_token)
          @token=_token
      end

      def to_s = token.str

      def location = "[Line #{token.line_no}]"

    end

    class List < Node

      def initialize(nodes)
        @children=nodes
      end

      def child(i) = @children[i]

      def size = @children.size

      def children = @children.each

      def to_s = "(#{@children.join(' ')})"

      def location = children.lazy.filter_map {|c| c.location }.first 
      # first truthy location

    end

    class NumLiteral < Leaf
      
      def val = token.num
    
    end

    class Name < Leaf
      
      def name = token.str

    end

    class BinExpr < List

      def left = child 0

      def operator = child(1).token.str

      def right = child 2

    end

    class PrimaryExpr < List

      def self.create(nodes) = nodes.size==1 ? nodes[0] : self.new(nodes)
      
    end

    class NegExpr < List

      def operand = child 0

      def to_s = "-#{operand}"
      
    end

    class BlockStmnt < List

    end

    class IfStmnt < List

      def condition = child 0

      def then_block = child 1

      def else_block = size > 2 ? child(2) : nil

      def to_s = "(if #{condition} #{then_block} else #{else_block})"
      
    end

    class WhileStmnt < List

      def condition = child 0

      def body = child 1

      def to_s = "(while #{condition} #{body})"
      
    end

    class NullStmnt < List

    end

    class StrLiteral < Leaf

      def value = token.str

    end
  end
end
