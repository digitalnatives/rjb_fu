
module ExcelFu

  module SheetMixin
    # you can write custom sheet code here
  end

  class Workbook

    require 'bigdecimal'

    def initialize()
      begin
        RjbFu::load_rjb
        @jFileInputStream = Rjb::import( 'java.io.FileInputStream' )
        @jFileOutputStream = Rjb::import( 'java.io.FileOutputStream' )
        @jWorkbookFactory = Rjb::import( 'org.apache.poi.ss.usermodel.WorkbookFactory' )
        @jWorkbook = Rjb::import( 'org.apache.poi.ss.usermodel.Workbook' )
        @jHSSFWorkbook = Rjb::import( 'org.apache.poi.hssf.usermodel.HSSFWorkbook' )
        @jXSSFWorkbook = Rjb::import( 'org.apache.poi.xssf.usermodel.XSSFWorkbook' )
        @jHSSFSheet = Rjb::import( 'org.apache.poi.hssf.usermodel.HSSFSheet' )
        @jXSSFSheet = Rjb::import( 'org.apache.poi.xssf.usermodel.XSSFSheet' )
        @jDateUtil = Rjb::import( 'org.apache.poi.ss.usermodel.DateUtil' )
        @jIndexedColors = Rjb::import( 'org.apache.poi.ss.usermodel.IndexedColors' )
        @jCellStyle = Rjb::import( 'org.apache.poi.ss.usermodel.CellStyle' )
        @jRow = Rjb::import( 'org.apache.poi.ss.usermodel.Row' )
        @jFont = Rjb::import( 'org.apache.poi.ss.usermodel.Font' )
      rescue => e
        puts "ExcelFu Init Exception: #{e.message}"
        puts "ExcelFu Init Backtrace: #{e.backtrace.join(' ')}"
      end

      # extending Sheet
      #@jXSSFSheet.class_eval do
      #  include ExcelFu::SheetMixin
      #end
      #@jHSSFSheet.class_eval do
      #  include ExcelFu::SheetMixin
      #end

    end

    def load_file( excelFile )
      input = @jFileInputStream.new_with_sig('Ljava.lang.String;', excelFile )
      @wb = @jWorkbookFactory.create( input )
      @wb.getNumberOfSheets()
    end

    def close_file
      @wb = nil
    end

    def save_file( outputFile )
      fileOut = @jFileOutputStream.new( outputFile )
      @wb.write(fileOut)
      fileOut.close()
    end

    def get_sheet( i )
      @wb.getSheetAt( i )
    end

    def get_num_rows( sheet )
      sheet.getPhysicalNumberOfRows()
    end

    def get_all_rows( sheet )
      rows = []
      rit = sheet.rowIterator()
      while rit.hasNext()
        row = rit.next()
        rows << self.get_row_data( row )
      end
      rows
    end

    # empty_cells = integer - sets Row.MissingCellPolicy (http://poi.apache.org/apidocs/org/apache/poi/ss/usermodel/Row.html)
    # 1 = CREATE_NULL_AS_BLANK
    # 2 = RETURN_BLANK_AS_NULL
    # 3 = RETURN_NULL_AND_BLANK
    def get_row_data( row, empty_cells = 3 )
      cell_policy = case empty_cells
        when 1 then @jRow.CREATE_NULL_AS_BLANK
        when 2 then @jRow.RETURN_BLANK_AS_NULL
        else @jRow.RETURN_NULL_AND_BLANK
      end
      data = []
      0.upto( row.getLastCellNum() ) do |i|
        cell = row.getCell( i, cell_policy )
        unless cell.nil?
          cv = self.cell_value(cell)
          data << cv
        end
      end
      data
    end

    def set_row_error( row, msg )
      lcn = row.getLastCellNum()
      cell = row.createCell( lcn + 1 )
      cell.setCellValue( msg )
      style = @wb.createCellStyle()
      style.setFillForegroundColor( @jIndexedColors.ORANGE.getIndex() )
      style.setFillPattern( @jCellStyle.SOLID_FOREGROUND )
      cell.setCellStyle(style)
    end

    CELL_TYPE_BLANK = 3
    CELL_TYPE_BOOLEAN = 4
    CELL_TYPE_ERROR = 5
    CELL_TYPE_FORMULA = 2
    CELL_TYPE_NUMERIC = 0
    CELL_TYPE_STRING = 1

    def cell_value(cell)
      case cell.getCellType()
      when CELL_TYPE_BLANK; ''
      when CELL_TYPE_BOOLEAN; cell.getBooleanCellValue()
      when CELL_TYPE_ERROR; nil
      when CELL_TYPE_FORMULA; cell.getCellFormula()
      when CELL_TYPE_NUMERIC
        if @jDateUtil.isCellDateFormatted(cell)
          p = cell.getDateCellValue()
          Time.at(p.getTime()/1000)
        else
          val = cell.getNumericCellValue()
          if val.to_i.to_f == val
            val.to_i
          else
            val
          end
        end
      when CELL_TYPE_STRING
        cell.getStringCellValue()
      else
        raise "Unexpected cell type: #{cell.getType()}"
      end
    end

    # create workbook type by file extension
    # optional data = 2 dimensional array, with cell values
    def create( filename, data = nil )
      file_ext = File.extname( filename )
      @wb = case file_ext
        when '.xls' then @jHSSFWorkbook.new()
        when '.xlsx'then @jXSSFWorkbook.new()
        else raise "Unknown file type, use xls or xlsx!"
      end

      # create sheet
      sheet = @wb.createSheet("1")

      import_array( sheet, data ) unless data.nil?

      @wb
    end

    # import array to a specified sheet - started from first row
    # important: overwrites existing cell values
    def import_array( sheet, data )
      # check data array
      raise "data can only be a 2-dimensional array!" unless data.instance_of?( Array ) && data.length > 0
      # iterate array rows
      data.each_with_index do |r,ri|
        create_row_from_array( sheet, ri, r )
      end
      # optional helper:
      # CreationHelper createHelper = wb.getCreationHelper();
      # row.createCell(2).setCellValue(createHelper.createRichTextString("This is a string"));
    end

    # add new row to the end of the selected sheet
    # heading - highlighted rows with specific style
    def add_row( sheet, data, heading = false )
      create_row_from_array( sheet, get_num_rows( sheet ), data, heading )
    end

    # this use the new stylable api internally
    def create_row_from_array( sheet, row_index, array, heading = false )
      create_styled_row_from_array( sheet, row_index, array, heading ? { :heading => true } : { :heading => false } )
    end

    def value_validator( cell, value )
      value = value.to_s('F') if value.is_a?( BigDecimal )
      cell.setCellValue(value)
    end

    # new, styleable API
    def create_styled_row_from_array( sheet, row_index, array, styles = { :heading => false } )
      raise "input array can only be a 1-dimensional array" unless array.instance_of?( Array )
      # Rows are 0 based.
      row = sheet.createRow(row_index)
      # iterate array cells
      array.each_with_index do |c,ci|
        cell = row.createCell(ci)
        # write values
        value_validator( cell, c )

        cell_style = {}
        cell_style[:heading] = true if styles[:heading]
        cell_style.merge!( styles[:columns][ci] ) if styles.has_key?( :columns ) && styles[:columns][ci]
        style_cell(cell, cell_style)
      end
    end

    def style_cell(cell, cell_style = {})
      if cell_style[:heading]
        style = @wb.createCellStyle();
        font = @wb.createFont();
        font.setBoldweight(@jFont.BOLDWEIGHT_BOLD);
        style.setFont(font);
        cell.setCellStyle(style);
      end

      if cell_style.keys.any?
        style = @wb.createCellStyle();
        border_styles = {:thin => @jCellStyle.BORDER_THIN, :medium => @jCellStyle.BORDER_MEDIUM, :thick => @jCellStyle.BORDER_THICK}

        cell_style.each_pair do |attrib, value|
          if attrib == :border_top
            style.setBorderTop(border_styles[value.to_sym]);
            style.setBottomBorderColor(@jIndexedColors.BLACK.getIndex());
          elsif attrib == :border_right
            style.setBorderRight(border_styles[value.to_sym]);
            style.setBottomBorderColor(@jIndexedColors.BLACK.getIndex());
          elsif attrib == :border_bottom
            style.setBorderBottom(border_styles[value.to_sym]);
            style.setBottomBorderColor(@jIndexedColors.BLACK.getIndex());
          elsif attrib == :border_left
            style.setBorderLeft(border_styles[value.to_sym]);
            style.setBottomBorderColor(@jIndexedColors.BLACK.getIndex());
          elsif attrib == :align
            aligns = {:left => style.ALIGN_LEFT, :center => style.ALIGN_CENTER}
            style.setAlignment( aligns[value.to_sym] );
          elsif attrib == :bold
            font = @wb.createFont();
            font.setBoldweight(@jFont.BOLDWEIGHT_BOLD);
            style.setFont(font);
          end
        end

        cell.setCellStyle(style);
      end

    end

  end # class

end # module
