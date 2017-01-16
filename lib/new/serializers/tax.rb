module Fiscalizer
  module Serializers
    class Tax
      def initialize(xml, object)
        @xml = xml
        @object = object
      end

      attr_reader :xml, :object

      def call
        add_vat_tax
        add_spending_tax
        add_other_taxes
        add_general_tax_info
      end

      private

      def add_vat_tax
        return if object.tax_vat.empty?

        xml['tns'].Pdv do
          object.tax_vat.each do |tax|
            add_tax(tax)
          end
        end
      end

      def add_spending_tax
        return if object.tax_spending.empty?

        xml['tns'].Pnp do
          object.tax_spending.each do |tax|
            add_tax(tax)
          end
        end
      end

      def add_other_taxes
        return if object.tax_other.empty?

        xml['tns'].OstaliPor do
          object.tax_other.each do |tax|
            add_tax(tax, true)
          end
        end
      end

      def add_tax(tax, include_name = false)
        xml['tns'].Porez do
          xml['tns'].Naziv tax.name if include_name
          xml['tns'].Stopa tax.rate_str
          xml['tns'].Osnovica tax.base_str
          xml['tns'].Iznos tax.total_str
        end
      end

      def add_general_tax_info
        add_tax_liberation
        add_tax_margin
        add_non_taxable
      end

      def add_tax_liberation
        return if object.value_tax_liberation_str.nil?
        xml['tns'].IznosOslobPdv object.value_tax_liberation_str
      end

      def add_tax_margin
        return if object.value_tax_margin_str.nil?
        xml['tns'].IznosMarza object.value_tax_margin_str
      end

      def add_non_taxable
        return if object.value_non_taxable_str.nil?
        xml['tns'].IznosNePodlOpor object.value_non_taxable_str
      end
    end
  end
end
