RailsPowergrid._GridStruct.Scrolling =
  _focusOnLastRowPosition: ->
    dataBlock = @getDOMNode().querySelector(".powergrid-data-content-wrapper")
    height = dataBlock.offsetHeight
    scroll = dataBlock.scrollTop

    row = @rows[@lastRowPosition].getDOMNode()

    wantedScroll = row.offsetTop + row.offsetHeight
    minScrollWanted = Math.max(0, row.offsetTop + row.offsetHeight-height)
    maxScrollWanted = row.offsetTop

    dataBlock.scrollTop = Math.max(minScrollWanted,Math.min(maxScrollWanted,scroll))


  handleScrolling: (evt) ->
    scroll = evt.target.scrollTop + evt.target.offsetHeight
    height = evt.target.scrollHeight

    if scroll>=height-250
      @fetchNextPage()