#
# ********* PREDICATOR ***************************************
# *****   I'll be back! **************************************
#                     ______
#                    <((((((\\\
#                    /      . }\
#                    ;--..--._|}
# (\                 '--/\--'  )
#  \\                | '-'  :'|
#   \\               . -==- .-|
#    \\               \.__.'   \--._
#    [\\          __.--|       //  _/'--.
#    \ \\       .'-._ ('-----'/ __/      \
#     \ \\     /   __>|      | '--.       |
#      \ \\   |   \   |     /    /       /
#       \ '\ /     \  |     |  _/       /
#        \  \       \ |     | /        /
#  snd    \  \      \        /
#
# Make easy request on multiple fields without hassle
# (for you, because lot of hassle from my point of view!)
#
# It works with a parser on the javascript side
# Which transform a ActiveRecord-where-string-like clause
# Into a JSON tree
# Then get it back here and transform the tree to
# a ActiveRecord-where/having-string clause.
#
# Yep. FYI, The hassle is about the HAVING clause
# It occurs when we want to filter on a column which is not
# a real column but a aggregated column (like count(*)+group by)
# The was is this:
#
# WHERE a=1 AND (b=2 OR COUNT(*)=3)
#
# Should be translated in
#
# WHERE a=1
# HAVING b=2 OR COUNT(*)=3
#
# (Note the fact the b=2 should be in having, thanks to the OR operator...)
#
# This module is actually coupled with RailsPowergrid
# But I secretly want to make it independant.
# The only problem is - I'm lazy - and the column aggregation tag fields should be
# passed in some way (check the comments below).
# Plus the arel_table for ambiguous columns...
#
RailsPowergrid::_require("predicator/node")
RailsPowergrid::_require("predicator/ext")

module Predicator
  class << self
    def create_predicate query, parameters, grid, opts
      return query if parameters.length == 0

      _opts = {grid: grid}.merge(opts)

      unless opts[:double_operators][parameters.keys.first.to_sym]
        # Case happening 90% of the time:
        # when only on parameter is filtered,
        # the request will be like:
        # {operator: ["field", "value"] }.
        #
        # We change this to:
        #
        # and: { operator: ["field", "value"]}
        # which is virtually doing nothing except
        # beginning our condition tree by a
        # BinaryOperator (and/or).
        parameters = {:and => [parameters]}
      end

      permits = grid.predicator_permit

      query_tree = Predicator::BinaryNode.new(nil, query, parameters, _opts)

      # Optimize the tree ASAP so less operations later
      query_tree.optimize

      # Stop if not permitted
      query_tree.each_simple_node do |n|
        if not permits.include?(n.field.to_sym)
          raise "Parameter unpermitted: `#{n.field}`, authorized = #{permits.inspect}"
        end
      end

      # Diffuse to up the aggregate value.
      # Aggregated fields cannot be placed into the where clause but will go to
      # the having clause.
      #
      # if X is aggregate and Y is not,
      # (X OR Y) should be aggregate while (X AND Y) is not...
      query_tree.diffuse_aggregate_tag

      where = query_tree.where_clause
      having = query_tree.having_clause

      if where && !where.strip.empty?
        query = query.where(where)
      end

      if having && !having.strip.empty?
        query = query.having(having)
      end

      query
    end
  end #class <<self

  DEFAULT_OPTS = {
    operators: {
      eq:     "=",
      neq:    "<>",
      gt:     ">",
      lt:     "<",
      gte:    ">=",
      lte:    "<=",
      :in => "IN",
      like:   "LIKE",
      ilike:  "ILIKE",
      null: "NULL"
    },
    double_operators: {
      :and => "AND", :or => "OR"
    }
  }

end

