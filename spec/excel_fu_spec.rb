# encoding: UTF-8
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe "ExcelFu" do

  describe "testing Excel import/export with POI" do

    before(:each) do
      @workbook = ExcelFu::Workbook.new
      @xls_input = File.join( File.dirname(__FILE__), 'files', 'Book1.xls' )
      @xlsx_input = File.join( File.dirname(__FILE__), 'files', 'Book1.xlsx' )
      @xls_fonts_input = File.join( File.dirname(__FILE__), 'files', 'font_problem.xls' )
      @xls_output = File.join( File.dirname(__FILE__), 'files', 'Book2.xls' )
      @xlsx_output = File.join( File.dirname(__FILE__), 'files', 'Book2.xlsx' )
      @overwritable_file = File.join( File.dirname(__FILE__), 'files', 'Book3.xlsx' )
      @created_file = File.join( File.dirname(__FILE__), 'files', 'Book4.xls' )
      @styled_file = File.join( File.dirname(__FILE__), 'files', 'styled_rows.xls' )
      @styled_output_file = File.join( File.dirname(__FILE__), 'files', 'styled_rows_output.xls' )
      FileUtils.rm_rf @xls_output
      FileUtils.rm_rf @xlsx_output
      FileUtils.rm_rf @styled_output_file
    end

    after(:each) do
      FileUtils.rm_rf @xls_output
      FileUtils.rm_rf @xlsx_output
    end

    it "should import an Excel (XLS) file and count sheets" do
      res = @workbook.load_file( @xls_input )
      res.should be_eql( 3 )
    end

    it "should import an Excel (XLS) file and extract all rows to ruby array" do
      @workbook.load_file( @xls_input )
      s = @workbook.get_sheet( 0 )
      data = @workbook.get_all_rows( s )
      data.length.should be_eql( 3 )

      first_row = data[0]
      first_cell = first_row[0]
      first_cell.should be_eql( "Speciális stringek és formulák" )
    end

    it "should import an Excel (XLS) file, process rows, set errors and save back the file" do
      @workbook.load_file( @xls_input )
      s = @workbook.get_sheet( 0 )
      rit = s.rowIterator()
      while rit.hasNext()
        row = rit.next()
        @workbook.set_row_error( row, "Some error!" )
        res = @workbook.get_row_data( row, false )
        res[-1].should be_eql( "Some error!" )
      end

      @workbook.save_file( @xls_output )
      File.size?( @xls_output ).should be_eql(19456)
    end

    it "should import an Excel (XLS) file, process rows, count rows" do
      @workbook.load_file( @xls_input )
      s = @workbook.get_sheet( 0 )
      rit = s.rowIterator()
      counter = 0
      while rit.hasNext()
        row = rit.next()
        rownum = row.getRowNum()
        counter.should be_eql( rownum )
        counter+=1
      end
    end

    it "should import an XLSX file, process rows, set errors and save back the file" do
      @workbook.load_file( @xlsx_input )
      s = @workbook.get_sheet( 0 )
      rit = s.rowIterator()
      while rit.hasNext()
        row = rit.next()
        @workbook.set_row_error( row, "Some error!" )
        res = @workbook.get_row_data( row )
        res[-1].should be_eql( "Some error!" )
      end

      @workbook.save_file( @xlsx_output )
      File.size?( @xlsx_output ).should be_eql(8342)
    end

    it "should import an Excel (XLS) file and overwrite the original file" do
      FileUtils.cp( @xlsx_input, @overwritable_file )
      expect {
        @workbook.load_file( @overwritable_file )
        s = @workbook.get_sheet( 0 )
        rit = s.rowIterator()
        while rit.hasNext()
          row = rit.next()
          @workbook.set_row_error( row, "Some serious error, what will change the size of the sheet!" )
        end
        @workbook.save_file( @overwritable_file )
      }.to change { File.size?( @overwritable_file ) }.by(-1954)
      FileUtils.rm_rf( @overwritable_file )
    end

    it "should create a new (XLS, XLSX) workbook with some data and save file" do
      test_array = [
        [ 1, 2, 3 ],
        [ "test 1", "test 2", "test 3"],
        [ 1.33, 4.51, 9999.11 ],
        [], # empty row
        [ "single cell" ]
      ]
      @workbook.create( @created_file, test_array )
      @workbook.save_file( @created_file )
      File.size?( @created_file ).should be_eql(4096)

      # read back data for testing
      s = @workbook.get_sheet( 0 )
      saved_array = @workbook.get_all_rows( s )
      test_array.should be_eql( saved_array )

      FileUtils.rm_rf( @created_file )
    end

    it "should add new rows at the end of the sheet" do
      test_array = [
        [ "heading 1", "heading 2", "heading 3" ],
        [ "value 1", "value 2", "value 3" ]
      ]
      @workbook.create( @created_file )
      sheet = @workbook.get_sheet( 0 )
      @workbook.add_row( sheet, test_array[0], true )
      @workbook.add_row( sheet, test_array[1] )

      written_array = @workbook.get_all_rows( sheet )
      test_array.should be_eql( written_array )
    end

    it "should import an XLS file with different fonts, and process all rows" do
      @workbook.load_file( @xls_fonts_input )
      s = @workbook.get_sheet( 0 )
      rit = s.rowIterator()
      counter = 0
      while rit.hasNext()
        row = rit.next()
        if counter > 370 && counter < 390
          res = @workbook.get_row_data( row, 1 )
          if counter == 371
            res.length.should be_eql( 12 )
          elsif counter == 377
            res.length.should be_eql( 14 )
          end
        end
        counter+=1
      end
      counter.should be_eql( 2000 )
    end

    it "should work with bigdecimals" do
      require 'bigdecimal'
      test_array = [
        [ "heading 1", "heading 2", "heading 3" ],
        [ BigDecimal.new("2312312"), BigDecimal.new("2312312"), BigDecimal.new("2312312") ]
      ]
      @workbook.create( @created_file, test_array )
      @workbook.save_file( @created_file )
      File.size?( @created_file ).should be_eql(4096)

      FileUtils.rm_rf( @created_file )
    end

    it "should create row from array with style specified" do
      data = [
        [nil, "underlined", nil, 123456],
        [],
        ["align left", nil, nil, 12346],
        [],
        ["underlined all row", nil, nil, 123456],
        [],
        [nil, nil, nil, 123456],
        [],
        ["align","center", "bold"],
        [],
        [nil, "double bordered", nil, 123456],
        [],
        [nil, nil, nil, 123456]
      ]
      styles = [
        [nil, {:border_bottom => :thin}, {:border_bottom => :thin}, {:border_bottom => :thin}],
        [],
        [nil, nil, nil, {:align => :left}],
        [],
        [{:border_bottom => :medium}, {:border_bottom => :medium}, {:border_bottom => :medium}, {:border_bottom => :medium, :align => :left}],
        [],
        [nil, nil, nil, {:bold => true, :align => :left}],
        [],
        [{:align => :center, :bold => true}, {:align => :center, :bold => true}, {:align => :center, :bold => true}, nil],
        [],
        [nil, {:border_bottom => :medium, :border_top => :medium}, {:border_bottom => :medium, :border_top => :medium}, {:border_bottom => :medium, :border_top => :medium, :align => :left}],
        [],
        [nil, nil, nil, {:border_bottom => :thick, :border_top => :thick, :border_left => :thick, :border_right => :thick, :align => :left}]
      ]
      @workbook.create( @styled_output_file )
      sheet = @workbook.get_sheet( 0 )
      data.each_with_index do |r,ri|
        @workbook.create_styled_row_from_array( sheet, ri, r, { :columns => styles[ri]} )
      end
      @workbook.save_file( @styled_output_file )
      File.size?( @styled_output_file ).should be_eql( File.size?( @styled_file ) )
    end

  end

end # modul

