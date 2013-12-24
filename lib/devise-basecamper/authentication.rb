# lib/devise-basecamper/authentication.rb

module DeviseBasecamper
  module Authentication
    extend ActiveSupport::Concern

    module ClassMethods
      ## Override the find_for_authentication finder
      ##
      ## We will clean the conditions provided to make sure that the proper
      ## resource can/will be found.
      ##
      ##
      def find_for_authentication(conditions={})
        conditions = clean_conditions_for_subdomain(conditions)

        ## Process if "login" key used instead of default (:email)
        if authenticate_with_login?(conditions)
          find_for_authentication_with_login( authentication_keys, conditions )
        else
          super ## Execute original find_for_authentication code
        end
      end

      def authenticate_with_login?(conditions={})
        if conditions.any?
          authentication_keys.include?(basecamper[:login_attribute]) && conditions.include?(basecamper[:login_attribute])
        else
          authentication_keys.include? basecamper[:login_attribute]
        end
      end

      private # -------------------------------------------

      ## Search for the resource identified in the basecamper config and return it
      ## to the caller
      def find_resource_by_subdomain(conditions)
        resource            = self.basecamper[:subdomain_class].to_s.camelize.constantize
        subdomain_field     = self.basecamper[:subdomain_field]

        return resource.to_adapter.find_first(subdomain_field => conditions[:subdomain])
      end

      ## We are going to look for the subdomain condition.  If present, we will translate
      ## the subdomain to a valid "id", add the ID to the conditions for use in the DB
      ## query built and remove thd field from the conditions to avoid issues down the
      ## chain.
      ##
      def clean_conditions_for_subdomain(conditions={})
        if conditions[:subdomain].present?
          scope_field, subdomain_field  = [self.basecamper[:scope_field], self.basecamper[:subdomain_field]]
          subdomain_resource            = find_resource_by_subdomain conditions
          conditions[scope_field]       = (subdomain_resource.nil?) ? nil : subdomain_resource.id
          conditions.delete(subdomain_field)
        end

        return conditions
      end

      ## If devise is configured to allow authentication using either a username
      ## or email, as described in the wiki we will need to process the find
      ## appropriately.
      def find_for_authentication_with_login(required_attributes={}, attributes={}, error=:invalid)
        resource    = nil
        attributes  = devise_parameter_filter.filter(attributes)

        basecamper[:login_fields].each do |field|
          login_field = field.downcase.to_sym

          resource    = to_adapter.find_first({
            login_field               => attributes[ basecamper[:login_attribute] ],
            basecamper[:scope_field]  => attributes[basecamper[:scope_field]]
          })

          break unless resource.nil?
        end

        unless resource
          resource = new

          required_attributes.each do |key|
            unless key == basecamper[:subdomain_field]
              resource.send("#{ key }=", attributes[key])
              resource.errors.add(key, attributes[key].present? ? error : :blank)
            end
          end
        end

        return resource
      end

      ## --------------------------------------------------
    end
  end
end