require 'rubygems'
require 'sinatra'
require 'smsapp_models.rb'
require 'smsapp_apps.rb'

get '/' do
  load 'smsapp_models.rb'
  load 'smsapp_apps.rb'
  phone = params[:phoneno]
  message = params[:content]
  longcode = nil

  if phone.blank? || message.blank?
    halt "Go away!"
  end

  scanned_msg = message.scan(/(\w+) (.*)/)
  keyword = scanned_msg[0][0]
  app_message = scanned_msg[0][1]
  Smsapp::App_Logger.info "Will look for keyword #{keyword}"

  unless (kw = Keyword.find_by_name(keyword))
    halt "Unallocated keyword!"
  end
  app = Object::const_get(kw.smsapp.name).find(kw.smsapp_id)
  ph = Phone.new(phone)
  if ph.invalid?
    halt "Invalid phone number"
  else
    app.incoming(longcode, keyword, ph, app_message, Time.now.to_i)
  end
  "Successful"
end

#TODO: Need one or more dedicated long or short codes
#TODO: Need to set callback URLs on all the above codes such that the receiving code can be figured out
#TODO: Need an enterprise account with dynamic masking enabled and dndCheck disabled
