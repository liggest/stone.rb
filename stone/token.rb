
module Stone
  class Token
    attr_reader :line_no

    def initialize(line_no)
      @line_no=line_no
    end

    EOF=self.new(-1)
    EOL=?\n

    # def is_identifier?
    def is_name?
      false
    end

    # def is_number?
    def is_num?
      false
    end

    # def is_string?
    def is_str?
      false
    end

    # def number
    def num
      raise StoneError,"this token dosen't contain a number"
    end

    # def string
    def str
      ""
    end
  end

  class NumToken < Token
    attr_reader :num

    def initialize(line_no,num)
      super(line_no)
      @num=num
    end

    def is_num?
      return true
    end

    def str
      return num.to_s
    end

  end

  class NameToken < Token
    attr_reader :name
    
    def initialize(line_no,name)
      super(line_no)
      @name=name
    end

    def is_name?
      true
    end

    def str
      name
    end
  end

  class StrToken < Token
    attr_reader :str

    def initialize(line_no,str)
      super(line_no)
      @str=str
    end

    def is_str?
      true
    end
  end
end
