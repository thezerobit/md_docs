require 'filemodel'

class PublicController < ApplicationController

  def index
    name = "index"
    @title = name.capitalize
    @model = FileModel.new unless @model
    @files = @model.get_files
    @filename = @model.get_filename(name)
    @contents = File.read(@filename)
    render "chapter"
  end

  def chapter
    name = params[:name]
    @title = name.capitalize
    @model = FileModel.new unless @model
    @files = @model.get_files
    @filename = @model.get_filename(name)
    @contents = File.read(@filename)
  end

end
