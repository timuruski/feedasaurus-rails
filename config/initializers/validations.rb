class OptionalValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # Optional attribute is optional.
  end
end
