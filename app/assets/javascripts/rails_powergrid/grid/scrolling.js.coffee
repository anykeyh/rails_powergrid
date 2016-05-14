RailsPowergrid._GridStruct.Scrolling =
  _focusOnLastRowPosition: ->
    dataBlock = @refs.wrapper
    height = dataBlock.offsetHeight
    scroll = dataBlock.scrollTop

    row = @rows[@lastRowPosition].refs.root

    wantedScroll = row.offsetTop + row.offsetHeight
    minScrollWanted = Math.max(0, row.offsetTop + row.offsetHeight-height)
    maxScrollWanted = row.offsetTop

    dataBlock.scrollTop = Math.max(minScrollWanted,Math.min(maxScrollWanted,scroll))


  handleScrolling: (evt) ->
    scroll = evt.target.scrollTop + evt.target.offsetHeight
    height = evt.target.scrollHeight

    for k,c of @rowChunks
      c.checkVisibility(evt.target.scrollTop, scroll)

    if scroll>=height-250
      @fetchNextPage()

  preventDefaultScrolling: (evt) ->
    return if Math.abs(evt.wheelDeltaX) > Math.abs(evt.wheelDeltaY)

    target = evt.currentTarget

    windowHeight  = target.offsetHeight
    currentScroll = target.scrollTop
    childHeight   = target.childNodes[0].offsetHeight
    delta         = evt.wheelDelta

    #So the page is not scrolling anymore when the mouse is on the grid
    if (delta<0 && (currentScroll >= childHeight - windowHeight)) or ( delta>0 && currentScroll <= 0)
      evt.preventDefault()
      evt.stopPropagation()
