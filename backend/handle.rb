require_relative "../stone.rb"

require "json"

module Stone
  class Token

    def EOF.as_json()
      { name: "EOF", str: "" }
    end

    def as_json()
      {
        name: self.class.name.split("::").last.downcase.delete_suffix("token"),
        str: str,
        lineNo: line_no
      }
    end

    def to_json(_)
      as_json.to_json(_)
    end
  end

  class StrToken

    def as_json()
      super.tap{|json| json[:str]=str.inspect }
    end
  end
end

def handle(conn,msg)
  json=JSON.parse(msg)
  unless json["type"].eql? "code"
    logger.info json["text"]
    return
  end
	lexer=Stone::Lexer.new StringIO.new(json["text"])
  tokens=[]
  until (token=lexer.read).eql? Stone::Token::EOF
    tokens << token
  end
  conn.write(JSON.generate(tokens)) unless tokens.empty?
  conn.flush
rescue RuntimeError => e
  conn.write(JSON.generate({name:"error",str:e.message}))
end
