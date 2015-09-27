#
# SmartDate
#
# Using chronic to generate SQL query.
# Loaded only if chronic is added to the gemlist.
#
#
require 'chronic'
module RailsPowergrid::SmartDate
  class << self
    # Return the sql to filter for this period.
    def operation field, operator, start_date, end_date
      case operator
      when "="
        "#{field} >= #{start_date} AND #{field} < #{end_date}"
      when "<>"
        "#{field} < #{start_date} OR #{field} >= #{end_date}"
      when ">"
        "#{field} >= #{end_date}"
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

    def generate_sql field, operator, value
      if value!="NULL" && value!="NOT NULL"
        real_date = Chronic.parse(value, guess: false)

        if real_date.nil?
          ActiveRecord::Base::sanitize(false) #`False` filter?
        else
          operation field, operator, ActiveRecord::Base::sanitize(real_date.begin),
            ActiveRecord::Base::sanitize(real_date.end)
        end
      else
        "#{field} #{operator} #{value}"
      end
    end
  end
end