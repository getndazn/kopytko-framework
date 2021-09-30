' @class
function HttpInterceptor() as Object
  prototype = {}

  ' Used to catch urlTransfer - roUrlTransfer object
  ' https://developer.roku.com/docs/references/brightscript/components/rourltransfer.md
  ' @abstract
  ' @param {HttpRequest} request
  ' @param {Object} urlTransfer
  prototype.interceptRequest = sub (request as Object, urlTransfer as Object)
  end sub

  ' Used to catch request options and urlEvent - roUrlEvent object
  ' https://developer.roku.com/docs/references/brightscript/events/rourlevent.md
  ' @abstract
  ' @param {HttpRequest} request
  ' @param {Object} urlTransfer
  prototype.interceptResponse = sub (request as Object, urlEvent as Object)
  end sub

  return prototype
end function
