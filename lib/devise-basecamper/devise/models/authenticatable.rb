# lib/devise-basecamper/devise/models/authenticatable.rb
#
# This module will make sure to remove the subdomain field by default
# from devise models that are NOT using basecamper.  That way the
# finders will try searching on fields in your database that may not
# exist.
##
module Devise
  module Models
    module Authenticatable
      module ClassMethods
        def find_for_authentication(conditions={})
          conditions.delete(:subdomain)
          find_first_by_auth_conditions(conditions)
        end
      end
    end
  end
end