FilterColumn = React.createClass
  render: ->
    <div className="powergrid-filter">
      <div className="powergrid-operation"></div>
    </div>
RailsPowergrid.FiltersBar = React.createClass
  render: ->
    <div className="powergrid-clearfix powergrid-filter-bar">
      {
        for x in @props.columns
          <FilterColumn parent=@props.parent data=x key="#{x.field}" />
      }
    </div>