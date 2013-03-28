class OptionalValidator < ActiveModel::EachValidator
  # Optional attribute is optional.
  def validate(record); end
  def validate_each(record, attribute, value); end
end

ActiveRecord::Base.class_eval do
  def self.validates_as_optional(*attr_names)
    validates_with OptionalValidator, _merge_attributes(attr_names)
  end
end
