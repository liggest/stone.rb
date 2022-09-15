require 'sinatra'

require 'async/websocket/adapters/rack'
require 'set'
require 'stringio'

require_relative './handle.rb'

Connections = Set.new

set :server, :falcon
set :public_folder, './page'

get '/' do
  send_file './page/index.html'
end

get '/ws' do
  Async::WebSocket::Adapters::Rack.open(request.env, protocols: ['ws']) do |connection|
		Connections << connection
		
		while message = connection.read
			Connections.each do |connection|
        logger.info "Received: #{message.to_str}"
				handle(connection,message)
				# connection.write(message)
				# connection.flush
			end
		end
	ensure
		logger.info "Closed..."
		Connections.delete(connection)
	end or [404, {}, []]
end


