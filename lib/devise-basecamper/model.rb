module Devise
  module Models
    module Basecamper
      extend ActiveSupport::Concern

      module ClassMethods
        def devise_basecamper(opts={})
          defaults = {
            :subdomain_class  => :account,
            :subdomain_field  => :subdomain,
            :scope_field      => :account_id,
            :login_fields     => [:username, :email]
          }
          @devise_basecamper_settings = defaults.merge(opts)
        end

        def basecamper
          self.devise_basecamper if @devise_basecamper_settings.nil?
          return @devise_basecamper_settings
        end

        ## Methods ------------------------------------------------------------

        def find_for_authentication(conditions={})
          authentication_keys = Devise.authentication_keys

          ## Process subdomain info by finding the parent resource id into the conditions
          conditions = clean_conditions_for_subdomain(conditions)

          ## Process if "login" key used instead of default (:email)
          if conditions[:login].present? && authentication_keys.include?(:login)
            resource = find_with_login_instead_of_default(conditions)
            return resource
          end

          ## Execute original find_for_authentication code
          super
        end

        # TODO: Probably should break this out or atleast put some conditions in place
        # so that this method is only included when "RECOVERABLE" is a specified option
        # for the resource.
        #
        # We want to override this method to find our users within the scope
        # of our subdomain.
        def send_reset_password_instructions(attributes={})
          send_instructions_for(:reset_password, attributes)
        end

        def send_confirmation_instructions(attributes={})
          send_instructions_for(:confirmation, attributes)
        end

        private

        def send_instructions_for(action_method, attributes={})
          scope_field           = self.basecamper[:scope_field].downcase.to_sym
          subdomain_resource    = find_subdomain_resource(attributes[:subdomain])
          subdomain_resource_id = subdomain_resource.nil? ? nil : subdomain_resource.id
          reset_password_keys   = Devise.reset_password_keys

          ## Find our resource for sending the email
          if attributes[:login].present? && reset_password_keys.include?(:login)
            resource = find_with_login_instead_of_default(attributes)
          else
            resource = find_or_initialize_with_errors(reset_password_keys,{
              :email => attributes[:email], scope_field => subdomain_resource_id
            })
          end

          resource.send("send_#{action_method.to_s}_instructions") if !resource.nil? && resource.persisted?
          return resource
        end

        private # -------------------------------------------------------------

        ## If devise is configured to allow authentication using either a username
        ## or email, as described in the wiki we will need to process the find
        ## appropriately.
        def find_with_login_instead_of_default(conditions={})
          resource      = nil
          scope_field   = self.basecamper[:scope_field]
          login_fields  = self.basecamper[:login_fields]

          login_fields.each do |login_field|
            login_field = login_field.downcase.to_sym
            resource    = to_adapter.find_first({
              login_field => conditions[:login],
              scope_field => conditions[scope_field]
            })

            break unless resource.nil?
          end

          return resource
        end

        ## Clean the conditions and set them appropriately for finding the resource
        ## with proper scoping.
        def clean_conditions_for_subdomain(conditions={})
          if conditions[:subdomain].present?
            subdomain               = conditions[:subdomain]
            scope_field             = self.basecamper[:scope_field]
            subdomain_field         = self.basecamper[:subdomain_field]
            subdomain_resource      = find_subdomain_resource(subdomain)
            conditions[scope_field] = (subdomain_resource.nil?) ? nil : subdomain_resource.id

            ## Remove the subdomain_field from the conditions - it is not needed
            conditions.delete(subdomain_field)
          end

          return conditions
        end

        ## Search for the resource identified in the basecamper config and return it
        ## to the caller
        def find_subdomain_resource(subdomain)
          resource            = self.basecamper[:subdomain_class].to_s.camelize.constantize
          subdomain_field     = self.basecamper[:subdomain_field]

          return resource.to_adapter.find_first(subdomain_field => subdomain)
        end
      end
    end
  end
end