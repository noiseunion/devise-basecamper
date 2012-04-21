module Devise
  module Models
    module Authenticatable
      module ClassMethods
        def find_for_authentication(conditions={})
          puts "crapper"
          conditions.delete(:subdomain)
          super
        end
      end
    end
  end
end