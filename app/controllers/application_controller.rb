class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  ROW_MARK = ";"
  COL_MARK = "^"
  STATUS_MARK = "¥"
  NEW_LINE_CODE = /\r\n|\r|\n/
  BR_TAG = "<br />"
end
