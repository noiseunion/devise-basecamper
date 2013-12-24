# lib/devise-basecamper/basecamper.rb

module DeviseBasecamper
  module Basecamper
    extend ActiveSupport::Concern

    module ClassMethods
      ## Helper method for configuration options on the model
      ##
      def devise_basecamper(opts={})
        defaults = {
          subdomain_class:  :account,
          subdomain_field:  :subdomain,
          scope_field:      :account_id,
          login_fields:     [:username, :email],
          login_attribute:  :login
        }

        @devise_basecamper_settings = defaults.merge(opts)
      end

      ## Quick access to the models configuration ---------
      ##
      def basecamper
        self.devise_basecamper if @devise_basecamper_settings.nil?
        return @devise_basecamper_settings
      end
    end

    ## ----------------------------------------------------
  end
end