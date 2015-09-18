require 'rubyXL'
class RailsPowergrid::GridController < ActionController::Base
  alias __index_old index
  def index
    if params[:format] == "xlsx"
      index_excel
    else
      __index_old
    end
  end

protected
  def index_excel
    prepare_collection_query

    workbook = RubyXL::Workbook.new
    sheet = workbook[0]

    sheet.sheet_name = @grid.name

    @grid.columns.each_with_index do |c, idx|
      sheet.add_cell(0, idx, c.label)
    end

    @query.all.map{|x| @grid.get_hash(x) }.each_with_index do |h, row|
      @grid.columns.each_with_index do |c, col|
        sheet.add_cell(row+1, col, h[c.name] )
      end
    end

    send_data workbook.stream.string,
      :content_type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      :filename => "#{@grid.name}.xlsx"
  end
end

RailsPowergrid::Grid::DSL::opts_default_actions += [:excel]
