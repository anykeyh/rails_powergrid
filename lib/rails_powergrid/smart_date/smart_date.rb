#
# SmartDate
#
# Using chronic to generate SQL query.
# Loaded only if chronic is added to the gemlist.
#
# Honestly chronic is not so good gem, but I didn't find
# anything that fit my needs.
# The first thing we date is it should be ALWAYS a range.
# Chronic helps doing it, but not so well, it's not possible
# to get range from year for example.
#
# Maybe later I would love to make my own date gem, simpler in some expression
# and more powerful for others (ex: "year 2015")
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