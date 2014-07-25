require "language_pack/java"
require "language_pack/tomcat"
require "language_pack/package_fetcher"

# General Language Pack module
module LanguagePack

  # detects which language pack to use
  # @param [Array] first argument is a String of the build directory
  # @return [LanguagePack] the {LanguagePack} detected
  def self.compile(*args)
    Dir.chdir(args.first)
    object1= Java.new(*args)
    object1.compile
    object2= Tomcat.new(*args)
    object2.compile
    #object2= Geronimo.new(*args)
    #object2.compile
   
  end

  
end
