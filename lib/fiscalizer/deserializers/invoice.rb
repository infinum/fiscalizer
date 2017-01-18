class Fiscalizer
  module Deserializers
    class Invoice < Base
      def unique_identifier
        element_value(root, 'Jir')
      end
    end
  end
end
