require 'filemodel'

class PublicController < ApplicationController

  def index
    @model = FileModel.new unless @model
    @files = @model.get_files
  end

  def chapter
    name = params[:name]
    @model = FileModel.new unless @model
    @filename = @model.get_filename(name)
    @contents = File.read(@filename)
  end

end
