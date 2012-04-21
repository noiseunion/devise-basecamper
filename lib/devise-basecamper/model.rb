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
      end
    end
  end
end