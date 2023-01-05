module Stone
  
  class BasicInterpreter

    attr_reader :file

    def initialize(parser=nil,env=nil,io:ARGF)
      @parser=_=parser # make steep happy
      @env=_=env
      @file=io

      if @file.eql? ARGF
        ARGF.instance_exec do
          #@type var current_file:IO?
          current_file=nil
          alias old_readline readline
          define_singleton_method :readline do |*args|
            # decorate readline for file tracking
            unless current_file.eql?(self.file)
              Kernel.puts "Stone File: #{self.filename}"
              current_file=self.file
            end
            old_readline *args
          end
        end
      end

    end

    def parser = @parser||=BasicParser.new

    def env = @env||=BasicEnv.new

    def run(parser,env)
      lexer=Lexer.new file
      until lexer.peek(0).eql? Token::EOF
        ast=parser.parse lexer
        next if ast.is_a?(AST::NullStmnt)
        result=ast.eval(env)
        puts "=> #{result}"
      end
    end

    def call = run(parser,env)

  end

  class FuncInterpreter < BasicInterpreter
    
    def parser = @parser||=FuncParser.new

    def env = @env||=NestedEnv.new

  end

  class ClosureInterpreter < FuncInterpreter

    def parser = @parser||=ClosureParser.new

  end

end
