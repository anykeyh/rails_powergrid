/*
 Parser rules for clause "WHERE"
 To use combined with powergrid gem for ruby on rails
*/
start=
 additive_test
 / atomic_test

variable=
  variable:([A-Za-z0-9\-_\.]+) { return variable.join(""); }


operator=
  operator_equals / operator_not_equals
  / operator_lesser_than_or_equals / operator_lesser_than
  / operator_greater_than_or_equals / operator_greater_than
  / variable:variable { return variable.toLowerCase();  }

operator_equals=
  ("==" / "=" / "is"space) { return "eq"; }

operator_not_equals=
  ("!=" / "<>" / "isnt"space ) { return "neq"; }

operator_greater_than=
 ">" { return "gt" }

operator_greater_than_or_equals=
 ">=" { return "gte" }

operator_lesser_than=
 "<" { return "lt" }

operator_lesser_than_or_equals=
 "<=" { return "lte" }

trim = [ ]*
space = [ ]+

atomic_test=
  (variable:variable trim operator:operator trim value:value) { 
    var h = {};
    h[operator] = [variable, value]
    return h;
  }
  /primary_test

primary_test=
  "(" trim test:additive_test trim ")" { return test; }
  / "(" start:start ")" { return start; }

additive_test2=
  left:atomic_test space op:boolean_operand space right:atomic_test{
    var h = {};
    h[op] = [left, right]
    return h;
  }

additive_test=
 left:additive_test2 space op:boolean_operand space right:additive_test2{
    var h = {};
    h[op] = [left, right]
    return h;
  }
 / left:additive_test2 space op:boolean_operand space right:atomic_test{
    var h = {};
    h[op] = [left, right]
    return h;
  }
 / additive_test2

boolean_operand=
  boolean_or / boolean_and


boolean_or=
  ("OR"i / "||") { return "or"; }

boolean_and=
  ("AND"i / "&&") { return "and"; }

value=
 "?"
 / symbol:(":"variable){return symbol.join("") }
