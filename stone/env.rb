
module Stone
  class BaseEnv
    
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
end
