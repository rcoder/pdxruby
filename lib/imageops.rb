module ImageOps

def resize(filename, geometry)
  begin
    require 'RMagick'
    im = Magick::ImageList.new filename
    im.change_geometry!(geometry){ |cols,rows,img| img.resize!(cols,rows) }
    im.write filename
  rescue LoadError
    convert = `which convert`.chomp
    if convert !~ /^no convert/
      system(convert, '-antialias', '-scale', geometry, filename, filename)
    end
  end
end

module_function :resize

end
