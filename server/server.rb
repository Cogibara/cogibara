require 'sinatra/base'

module Cogibara
  class SServer < Sinatra::Base
    configure do
      set :interface, Cogibara::Interface::Speech.new
    end

    get '/' do
      str = settings.interface.ask_string('helloo!!')
      str.message.to_s
    end

    run!
  end
end