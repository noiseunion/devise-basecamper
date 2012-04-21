require 'devise'
require 'devise-basecamper/version'
require 'devise-basecamper/devise/models/authenticatable'

Devise.add_module(:basecamper,
  :strategy   => false,
  :route      => :session,
  :controller => :sessions,
  :model      => 'devise-basecamper/model'
)
