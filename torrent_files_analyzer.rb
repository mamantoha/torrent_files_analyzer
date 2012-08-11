# encoding: utf-8

require 'sinatra/base'
require 'time'
require 'slim'
require 'bencode'

Slim::Engine.set_default_options :pretty => true

def generate_hash(files)
  array = files.inject([]) {|h, i| h << i['path'].join('/')}
  tree = array.inject({}) {|h, i| t = h; i.split("/").each {|n| t[n] ||= {}; t = t[n]}; h}

  return tree
end

class TorrentFilesAnalyzer < Sinatra::Base
  set :session, true

  get '/' do
    slim :index
  end

  post '/upload' do
    tempfile = params[:file][:tempfile]
    @data = BEncode.load_file(tempfile)

    @info = @data['info']
    @data = @data.delete_if{|k, v| k == 'info'}

    @files_tree = generate_hash(@info['files']) if @info['files']

    slim :upload
  end

  run! if app_file == $0
end
