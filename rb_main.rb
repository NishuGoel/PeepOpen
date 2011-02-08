#
# rb_main.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/15/10.
# Copyright Topfunky Corporation 2010. All rights reserved.
#

if (Dir.exist?(NSBundle.mainBundle.privateFrameworksPath))
  $:.map! { |x| x.sub(/^\/Library\/Frameworks/, NSBundle.mainBundle.privateFrameworksPath) }
  $:.unshift NSBundle.mainBundle.resourcePath.fileSystemRepresentation
end

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
framework 'BWToolkitFramework'

# HACK: From http://lists.macosforge.org/pipermail/macruby-devel/2009-May/001710.html
KInternetEventClass = 'GURL'.unpack('N').first
KAEGetURL = 'GURL'.unpack('N').first


# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  if path != main
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
