require 'filemodel'

class PublicController < ApplicationController

  def index
    @title = "Index"
    @model = FileModel.new unless @model
    @files = @model.get_files
  end

  def chapter
    name = params[:name]
    @title = name.capitalize
    @model = FileModel.new unless @model
    @filename = @model.get_filename(name)
    @contents = File.read(@filename)
  end

end
