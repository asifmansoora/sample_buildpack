require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"
require 'fileutils'
require "language_pack/java"

module LanguagePack
  class Tomcat
    
    
    
    include LanguagePack::PackageFetcher
    TOMCAT_CONFIG = File.join(File.dirname(__FILE__), "../../config/tomcat.yml")
    attr_reader :build_path, :cache_path

    # changes directory to the build_path
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end
   
    def compile
      Dir.chdir(@build_path) do
        install_tomcat
        #copy_webapp_to_geronimo
        #move_geronimo_to_root
      end
     
    end
   
    def install_tomcat
       
       #puts tomcat_package
       FileUtils.mkdir_p tomcat_home
       tomcat_tarball = "#{tomcat_home}/apache-tomcat-7.0.54.tar.gz"
       tomcat_package = tomcat_config["repository_root"]
       filename = tomcat_config["filename"]
       puts "------->Downloading #{filename}  from #{tomcat_package}"
       download_start_time = Time.now
       fetched_package=system("curl #{tomcat_package}/#{filename} -s -o #{filename}")
       puts "fetched to a location"
       #FileUtils.mv fetched_package, tomcat_tarball
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking tomcat"
       download_start_time = Time.now
       #unzip geronimo package in geronimo_home
       tar_output = run_with_err_output "tar pxzf #{fetched_package} -C #{tomcat_home}"
       #move contents of geronimo zip to geronimo_home
       #run_with_err_output("mv #{tomcat_home}/* #{tomcat_home} && " + "rm -rf #{geronimo_home}/geronimo-tomcat*")
       # delete downloaded zip as we have extracted it now. So the size of droplet will get reduced 
       #FileUtils.rm_rf tomcat_tarball
       puts "(#{(Time.now - download_start_time).duration})"

        #check for geronimo.sh if available means you have downloaded geronimo successfully
       unless File.exists?("#{tomcat_home}/bin/startup.sh")
         puts "Unable to retrieve tomcat"
         exit 1
       end
      puts "startup.sh exists"
    end
    def tomcat_config
      YAML.load_file(File.expand_path(TOMCAT_CONFIG))
    end
    #create deploy folder in geronimo_home for hot deployment
    def copy_webapp_to_geronimo
        run_with_err_output("mkdir -p #{geronimo_home}/deploy && mv * #{geronimo_home}/deploy")
    end
    
    def move_geronimo_to_root
      run_with_err_output("mv #{geronimo_home}/* . && rm -rf #{geronimo_home}")
    end
    def tomcat_home
      ".tomcat_home"
    end
    
    def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end
   end
end
