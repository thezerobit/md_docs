require 'filemodel'

def get_files
  files = []
  re = /^db\/files\/(\d+)_(.+)\.md$/
  filenames = Dir.glob("db/files/*")
  filenames.each { |filename|
    m = filename.match(re)
    files.push(m[2]) if m
  }
  return files
end

def get_filename(name)
  files = []
  re = /^db\/files\/(\d+)_(.+)\.md$/
  filenames = Dir.glob("db/files/*")
  filenames.each { |filename|
    m = filename.match(re)
    return filename if m[2] == name
  }
  nil
end


class PublicController < ApplicationController
  def index
    @files = get_files
  end

  def chapter
    name = params[:name]
    @filename = get_filename(name)
    @contents = File.read(@filename)
  end

end
