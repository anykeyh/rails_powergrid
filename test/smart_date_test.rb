require 'test_helper'

class SmartDateTest < ActiveSupport::TestCase
  test "format" do
    year = DateTime.now.year
    month = DateTime.now.month
    results = {
      #created_at > '2015-09-27 05:22:25.272249')
      "date > \"2016-1-1 00:00:00:00.000000\"" => ["2015", ">", "date"],
      "date < \"2015-1-1 00:00:00:00.000000\"" => ["2015", "<", "date"],
      "date >= \"2015-1-1 00:00:00:00.000000\"" => ["2015", ">=", "date"],
      "date >= \"2015-1-1 00:00:00:00.000000\"" => ["2015", ">=", "date"],
      "date >= \"#{year}-1-1 00:00:00.000000\" AND date < \"#{year}-2-1 00:00:00.000000\"" => ["January", "=", "date"],
      "date >= \"#{year}-1-2 00:00:00.000000\" AND date < \"#{year}-1-14 00:00:00.000000\"" => ["2-13 January", "=", "date"],
      "date >= \"#{year}-3-2 00:00:00.000000\" AND date < \"#{year}-3-14 00:00:00.000000\"" => ["2-13 Mar", "=", "date"],
      "date >= \"#{year}-3-31 00:00:00.000000\" AND date < \"#{year}-4-1 00:00:00.000000\"" => ["31 Mar", "=", "date"],
      "date >= \"#{year}-3-31 00:00:00.000000\" AND date < \"#{year}-4-1 00:00:00.000000\"" => ["31 March", "=", "date"],
      "date >= \"#{year}-3-31 00:00:00.000000\" AND date < \"#{year}-4-1 00:00:00.000000\"" => ["March, 31", "=", "date"],
      "date >= \"1987-3-31 00:00:00.000000\" AND date < \"1987-4-1 00:00:00.000000\"" => ["March 1987", "=", "date"],
      "date >= \"#{year}-3-31 00:00:00.000000\"" => ["31 Mars", ">", "date"],
    }

    results.each do |k,v|
      assert RailsPowergrid::SmartDate.parse(*v) == k
    end

    #assert_kind_of Module, RailsPowergrid
  end
end