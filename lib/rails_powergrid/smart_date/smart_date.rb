#
# SmartDate
#
# Using chronic to generate SQL query.
# Loaded only if chronic is added to the gemlist.
#
#
module RailsPowergrid::SmartDate
  class << self
    # Return the sql to filter for this period.
    def operation field, operator, start_date, end_date
      case operator
      when "="
        "#{field} >= #{start_date} AND #{field} < #{end_date}"
      when "!="
        "#{field} < #{start_date} OR #{field} >= #{end_date}"
      when ">"
        "#{field} > #{end_date}"
      when "<"
        "#{field} < #{start_date}"
      when ">="
        "#{field} >= #{start_date}"
      when "<="
        "#{field} < #{end_date}"
      else
        "#{field} #{operator} #{start_date}" #Fallback
      end
    end

    def generate_sql field, value, operator
      if value!="NULL" && value!="NOT NULL"
        real_date = Chronic.parse(value, guess: false)

        if real_date.nil?
          "0" #`False` filter?
        else
          operation field, operator, real_date.start, real_date.end
        end

      else
        "#{field} #{operator} #{value}"
      end
    end
  end
end