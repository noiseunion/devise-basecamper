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