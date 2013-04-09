module Devise
  module Models
    module Basecamper
      extend ActiveSupport::Concern

      module ClassMethods
        def devise_basecamper(opts={})
          defaults = {
            :subdomain_class  => :account,
            :subdomain_field  => :subdomain,
            :scope_field      => :account_id
          }
          @devise_basecamper_settings = defaults.merge(opts)
        end

        def basecamper
          self.devise_basecamper if @devise_basecamper_settings.nil?
          return @devise_basecamper_settings
        end

        def find_for_authentication(conditions={})
          if conditions[:subdomain].present?
              resource                                  = self.basecamper[:subdomain_class].to_s.camelize.constantize
              subdomain_source                          = resource.to_adapter.find_first(self.basecamper[:subdomain_field] => conditions[:subdomain])
              conditions[self.basecamper[:scope_field]] = (subdomain_source.nil?) ? nil : subdomain_source.id
              conditions.delete(self.basecamper[:subdomain_field])
          end
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
          resource          = self.basecamper[:subdomain_class].to_s.camelize.constantize
          subdomain_source  = resource.to_adapter.find_first(self.basecamper[:subdomain_field] => attributes[:subdomain])

          search_fields     = Devise.reset_password_keys
          search_fields << self.basecamper[:scope_field]

          Rails.logger.debug "hi there you lame turd."
          Rails.logger.debug search_fields.inspect

          # Execute the search
          action_object     = find_or_initialize_with_errors(search_fields, {
            :email => attributes[:email], self.basecamper[:scope_field] => (subdomain_source.nil? ? nil : subdomain_source.id.to_s)
          })
          action_object.send("send_#{action_method.to_s}_instructions") if action_object.persisted?
          action_object
        end
      end
    end
  end
end