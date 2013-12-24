module Devise
  module Models
    module Basecamper
      extend ActiveSupport::Concern

      included do
        include DeviseBasecamper::Basecamper
        include DeviseBasecamper::Authentication
        include DeviseBasecamper::Recoverable
        include DeviseBasecamper::Confirmable
      end
    end
  end
end
