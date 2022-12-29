
module Stone
  class Lexer
      BlankPattern=/\s*/
      CommentPattern=/\/\/.*/
      NumPattern=/[0-9]+/
      StrPattern=/"(\\"|\\\\|\\n|[^"\\])*"/
      # NamePattern=/[A-Z_a-z][A-Z_a-z0-9]*|==|<=|>=|&&|\|\||\p{Punct}/
      NamePattern=/[A-Z_a-z][A-Z_a-z0-9]*|==|<=|>=|&&|\|\||[[:punct:]]/
      # in utf-8
      # /\p{Punct}/ =~ ">"  => nil
      # /[[:punct:]]/ =~ ">"  => 0
      # Pattern=Regexp.new(
      Pattern=Regexp.compile(
        /#{BlankPattern}((#{CommentPattern})|(#{NumPattern})|(#{StrPattern})|#{NamePattern})?/
      )

      attr_reader :queue
      attr_reader :reader

      def initialize(reader)
        @more=true
        @queue=[]
        @reader=reader
      end

      def more? = @more

      def read
        # make steep happy
        return t = _ = queue.shift if fill_queue?(0)
        Token::EOF
      end

      def peek(n)
        return queue[n] if fill_queue?(n)
        Token::EOF
      end

      def fill_queue?(n)
        while n>=queue.size
          if more?
            readline
          else
            return false
          end
        end
        true
      end

      def readline
        line=reader.readline
        line_no=reader.lineno
        until line.empty?
          match=Pattern.match line
          if match
            add_token line_no,match
            line=match.post_match
          else
            raise ParseError, "bad token at line #{line_no}"
          end
        end
        queue << NameToken.new(line_no,Token::EOL)
      rescue EOFError
        @more=false
      rescue IOError => e
        raise ParseError,e
      end

      def add_token(line_no,match)
        m=match[1]
        return if !m  # blank
        return if match[2] # comment
        if match[3]
          token=NumToken.new line_no, m.to_i
        elsif match[4]
          token=StrToken.new line_no, str_literal(m)
        else
          token=NameToken.new line_no, m
        end
        queue << token
      end

      def str_literal(s) = s.undump # \"\\n\" => "\n"
  end
end
