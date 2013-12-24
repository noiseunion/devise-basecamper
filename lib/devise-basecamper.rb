require 'devise'
require 'devise-basecamper/version'
require 'devise-basecamper/devise/models/authenticatable'
require 'devise-basecamper/basecamper'
require 'devise-basecamper/authentication'
require 'devise-basecamper/recoverable'
require 'devise-basecamper/confirmable'

## Establish the namespace --------------------------------
module DeviseBasecamper
end

## Add the model to devise --------------------------------
Devise.add_module(:basecamper,
  :strategy   => false,
  :route      => :session,
  :controller => :sessions,
  :model      => 'devise-basecamper/model'
)
