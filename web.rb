require 'sinatra'
require 'json'

class Web < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, './public'
  end
end

require_relative 'helpers/init'
require_relative 'routes/init'
