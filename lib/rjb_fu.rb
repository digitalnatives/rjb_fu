require 'rubygems'
require 'rjb'

module RjbFu

  # :stopdoc:
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    @version ||= File.read(path('version.txt')).strip
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args, &block )
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = block.call
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args, &block )
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block
      begin
        $LOAD_PATH.unshift PATH
        rv = block.call
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  # LOAD JVM
  def self.load_rjb
    if Rjb::loaded?
      puts "---- RJB already loaded! ----"
      return
    end
    
    dir = ::File.expand_path(::File.dirname(__FILE__)) + "/../jar"
    if File.exist?(dir)
      jardir = File.join(dir, '**', '*.jar')
    else
      jardir = File.join('.','jar', '**', '*.jar')
    end
    jar_classpath = Dir.glob(jardir).join(':')
    # external jvm args (array)
    init_args = defined?(RJB_FU_JVM_ARGS) ? RJB_FU_JVM_ARGS : ["-Djava.awt.headless=true"]
    begin
      puts "----------------------------"
      puts "---- Loading JVM by RJB ----"
      puts "Jars: #{jar_classpath}"
      puts "JVM args: #{init_args.to_s}"
      puts "----------------------------"
      Rjb::load(classpath = ".:#{jar_classpath}", jvmargs=init_args)
    rescue => e
      puts "RjbFu classpath: #{jar_classpath}"
      puts "RjbFu Init Exception: #{e.message}"
      puts "RjbFu Init Backtrace: #{e.backtrace.join(' ')}"
    end
  end

end  # module RjbFu

RjbFu.require_all_libs_relative_to(__FILE__)
require 'excel_fu/excel_fu'
require 'pdf_fu/pdf_fu'

