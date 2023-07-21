' @import /components/ArrayUtils.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils

' Convert from IMF-fixdate format (Internet Message Format) to seconds
' @param {String} IMFFixdate - the IMF-Fixdate string (Eg. "Sun, 06 Nov 1994 08:49:37 GMT")
' @returns {Integer} the datetime in seconds (Eg. 784111777) or -1 for incorrect IMF-fixdate
function imfFixdateToSeconds(imfFixdate as String) as Integer
  regex = CreateObject("roRegex", "(\d+) (\w{3}) (\d+) (\d+):(\d+):(\d+)", "")

  matches = regex.match(imfFixdate)
  if (matches.isEmpty()) then return -1

  MONTH_SHORT_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  day = matches[1]
  month = (ArrayUtils().findIndex(MONTH_SHORT_NAMES, matches[2]) + 1).toStr()
  year = matches[3]
  hour = matches[4]
  minute = matches[5]
  second = matches[6]

  _dateTime = DateTime()
  ISOString = year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second
  _dateTime.fromISO8601String(isoString)

  return _dateTime.asSeconds()
end function
