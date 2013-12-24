module DeviseBasecamper
  module Confirmable
    extend ActiveSupport::Concern

    module ClassMethods
      ## Override for password resets -------------------
      def send_confirmation_instructions(attributes={})
        if confirm_with_login?
          subdomain_resource                      = find_resource_by_subdomain(attributes)
          attributes[ basecamper[:scope_field] ]  = subdomain_resource.nil? ? nil : subdomain_resource.id
          recoverable                             = find_for_authentication_with_login(reset_password_keys, attributes, :not_found)
        else
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
        end

        ## Now that we have found the recoverable, we are going to call the
        ## send_reset_password_instructions on the specific recoverable
        ##
        recoverable.send_confirmation_instructions if recoverable.persisted?
        recoverable
      end

      def confirm_with_login?(attributes={})
        if attributes.any?
          attributes.include?( basecamper[:login_attribute] ) && confirmation_keys.include?( basecamper[:login_attribute] )
        else
          reset_password_keys.include?( basecamper[:login_attribute] )
        end
      end
    end
  end
end