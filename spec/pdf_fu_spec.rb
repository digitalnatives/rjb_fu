
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe "PdfFu" do

  describe "testing XSL-FO transformation with FOP" do
    
    before(:each) do
      @converter = PdfFu::Converter.new
      @xsl_path = File.join( File.dirname(__FILE__), 'files', 'foptest.xsl' )
      @output_path = File.join( File.dirname(__FILE__), 'files', 'foptest.pdf' )
    end
    
    after(:each) do
      FileUtils.rm_rf @output_path
    end
    
    it "should convert an XML file to valid PDF document" do
      xml_path = File.join( File.dirname(__FILE__), 'files', 'foptest.xml' )
      @converter.xml2pdf( xml_path, @xsl_path, @output_path )
      
      File.size?(@output_path).should be_between(50000, 60000)
    end

    it "should fail with a non valid XML input document" do
      xml_path = File.join( File.dirname(__FILE__), 'files', 'foptest_invalid.xml' )
      lambda {
        @converter.xml2pdf( xml_path, @xsl_path, @output_path )
      }.should raise_error( Exception )
      
      File.size?(@output_path).should be_nil
    end
      
  end

end

