###
  Handlers for the ajax 'error' status.
  Decorative pattern:

  RailsPowergrid.ajax(...,
    error: RailsPowergrid.ValidationErrorHandler(RailsPowergrid.OtherErrorHandler)
  )
###

# BASIC HANDLER (fallback)
RailsPowergrid.ErrorHandler = (cb) ->
  (req) ->
    alert "An error happens processing the data. Please contact software support"
    console.log req.responseText


RailsPowergrid.ValidationErrorHandler = (cb) ->
  cb ?= RailsPowergrid.ErrorHandler()

  (req) ->
    if req.status == 422
      RailsPowergrid.ValidationErrorHandler.show(JSON.parse(req.response))
    else
      cb.apply(window, arguments)

RailsPowergrid.ValidationErrorHandler.show = (response) ->
  RailsPowergrid.Modal.show(
    <RailsPowergrid.Modal title="Error">
      <div className="powergrid-error-validation">
        <h3>{"Some errors prevent from editing the data:"}</h3>
        <ul>
          {
            for field, errors of response.errors
              console.log(field, errors)
              <li><strong>{field}:</strong> {errors.join(", ")}</li>
          }
        </ul>
      </div>
    </RailsPowergrid.Modal>
  )

