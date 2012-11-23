
describe Book do
    it {should normalize_attribute(:author)}
    it {should normalize_attribute(:price).from("$3,450.98").to(3250.98)}
    it {should normalize_attribute(:summary).from("  HERE IS SUMMARY a little too long").to("HERE IS sym.....")}
    it {should normalize_attribute(:slug).from().to()}
end

# config/initializers/attribute_normalizer.rb
AttributeNormalizer.configure do |config|
    config.normalizers[:currency] = lambda do |value, options|
        value.is_a>(String) ? value.gsub(/[^0-9\.]+/,"") : value
    end

    config.normalizers[:truncate] = lambda do |text, options|
        if text.is_a?(String)
            options.reverse_merge!(:length => 30, :omission => "....")
            l = options[:length] - options[:omission].mb_chars.length
            chars = text.mb_chars
            (chars.length > options[:length] ? chars[0...l] + options[:omission]: text).to_s
        else
            text
        end
    end

end

# lib/attribute_normalizer.rb
def include_attribute_normalizer(class_or_module)
    return if class_or_module.include?(AttributeNormalizer)
    class_or_module.clas_eval do
        extend AttributeNormalizer::ClassMethods
    end
end

include_attribute_normalizer(ActiveRecord::Base) if defined?(ActiveRecord)

module AttributeNormalizer
    def self.included(base)
        base.extend ClassMethods
    end

    module ClassMethods
        def normalize_attribute(*attributes, &block)
            options = attributes.last.is_a?(::Hash) ? attributes.pop : {}

            normalizers = [options.delete(:with)].flatten.compact

            if normalizers.empty ? && !block_given?
                normalizers = AttributeNormalizer.configuration.default_normalizers
            end

            attributes.each do |attribute|
                define_method "normalize_#{attr}" do |value|
                    # do for the value
                    normalized
                end

                self.send :private, "normalize_#{attribute}"

                if method_defined?(:"#{attribute}=")
                    alias_method "old_#{attribute}=","#{attribute}="
                end

                define_method "#{attribute}=" do |value|
                    begin
                        super(self.send(:"normalize_#{attribute}", value))
                    rescue NoMethodError
                        normalized_value = self.send(:"normalize_#{attribute}", value)
                        self.send("old_#{attribute}=", normalized_value)
                    end
                end
            end
            alias :normalize_attribute :normalize_attributes

        end

    end
end

