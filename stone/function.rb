
module Stone
  class Function
    attr_reader :params, :body, :env

    def initialize(_params,_body,_env)
      @params=_params
      @body=_body
      @env=_env
    end

    def new_env = NestedEnv.new env

    def to_s = "<func:#{object_id}>" # should use hash()?
  end
end
