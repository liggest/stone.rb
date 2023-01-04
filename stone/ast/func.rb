module Stone
  module AST

    class Params < List
      
      def name(i) = child(i).token.str

    end

    class DefStmnt < List

      def name = child(0)&.token.str

      def params = _=child(1) # make steep happy

      def body = _=child(2)

      def to_s = "(def #{name} #{params} #{body} )"

    end

    class Suffix < List

    end
    
    class Args < Suffix
      
    end

  end
  
end
