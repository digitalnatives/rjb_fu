
module PdfFu
  
  class Converter

    def initialize()
      RjbFu::load_rjb
      @config_path = ::File.expand_path(::File.dirname(__FILE__)) + "/../../config"
      begin
        @jFile = Rjb::import( "java.io.File" )
        @jFileOutputStream = Rjb::import( "java.io.FileOutputStream" )
        @jBufferedOutputStream = Rjb::import( "java.io.BufferedOutputStream" )
        @jTransformerFactory = Rjb::import( "javax.xml.transform.TransformerFactory" ) 
        @jStreamSource = Rjb::import( "javax.xml.transform.stream.StreamSource" ) 
        @jSAXResult = Rjb::import( "javax.xml.transform.sax.SAXResult" )
        @jFOUserAgent = Rjb::import( "org.apache.fop.apps.FOUserAgent" )
        @jFopFactory = Rjb::import( "org.apache.fop.apps.FopFactory" )
        @jMimeConstants = Rjb::import( "org.apache.fop.apps.MimeConstants" )
        @jConfiguration = Rjb::import( "org.apache.avalon.framework.configuration.Configuration" )
        @jConfigurationBuilder = Rjb::import( "org.apache.avalon.framework.configuration.DefaultConfigurationBuilder" )
      rescue => e
        puts "PdfFu Init Exception: #{e.message}"
        puts "PdfFu Init Backtrace: #{e.backtrace.join(' ')}"
      end
    end # method
    
    # files with full path
    def xml2pdf( xmlFile, xslFile, pdfFile )

      xml = @jFile.new( xmlFile ) 
      xslt = @jFile.new( xslFile )
      pdf = @jFile.new( pdfFile )
      config = @jFile.new( @config_path, "config.xml" )
      # configure fopFactory as desired
      fopFactory = @jFopFactory.newInstance( )
      fopFactory.setUserConfig( config )
      foUserAgent = fopFactory.newFOUserAgent()
        
      # Setup output
      out = @jFileOutputStream.new( pdf )
      out = @jBufferedOutputStream.new( out )
      # Construct fop with desired output format
      fop = fopFactory.newFop( @jMimeConstants.MIME_PDF, foUserAgent, out )
      # Setup XSLT
      factory = @jTransformerFactory.newInstance( )
      transformer = factory.newTransformer( @jStreamSource.new( xslt ) )
      # Setup input for XSLT transformation
      src = @jStreamSource.new( xml )
      # Resulting SAX events (the generated FO) must be piped through to FOP
      res = @jSAXResult.new( fop.getDefaultHandler() )
      # Start XSLT transformation and FOP processing
      transformer.transform( src, res )
      # Close output file
      out.close()

    end # method
  
  end # class
  
end # module

