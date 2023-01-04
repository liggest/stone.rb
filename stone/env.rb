
module Stone
  class BasicEnv
    
    attr_reader :vals
    
    def initialize
      @vals={}
    end

    def set(name,val)
      vals[name]=val
    end

    def get(name) = vals[name]

    def fetch(...) = vals.fetch(...)

    alias_method :[],:get
    alias_method :[]=,:set

  end

  class NestedEnv
    attr_reader :vals
    attr_accessor :outer

    def initialize(env=nil)
      @vals={}
      @outer=env
    end

    def get(name)
      val=vals[name]
      if val.nil? && !outer.nil?
        outer.get(name)
      else
        val
      end
    end

    def set(name,val)
      vals[name]=val
    end

    # dont check wether outer has `name`
    def set!(name,val) 
      vals[name]=val
    end

    def where(name)
      if !vals[name].nil?
        self
      else
        outer&.where name
      end
    end

  end
end
