module Stone
  
  class BasicInterpreter

    def initialize(parser=nil,env=nil)
      @parser=_=parser # make steep happy
      @env=_=env
    end

    def parser = @parser||=BasicParser.new

    def env = @env||=BasicEnv.new

    def run(parser,env)
      lexer=Lexer.new ARGF
      #@type var file:IO?
      file=nil
      until lexer.peek(0).eql? Token::EOF
        unless file.eql?(ARGF.file)
          puts "Stone File: #{ARGF.filename}"
          file=ARGF.file
        end
        ast=parser.parse lexer
        next if ast.is_a?(AST::NullStmnt)
        r=ast.eval(env)
        puts "=> #{r}"
      end
    end

    def call = run(parser,env)

  end

  class FuncInterpreter < BasicInterpreter
    
    def parser = @parser||=FuncParser.new

    def env = @env||=NestedEnv.new

  end

end
