class FileModel
  public 
  def get_files
    files = []
    re = /^db\/files\/(\d+)_(.+)\.md$/
    filenames = Dir.glob("db/files/*")
    filenames.sort!
    filenames.each { |filename|
      m = filename.match(re)
      files.push(m[2]) if m
    }
    return files
  end

  public
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

end
