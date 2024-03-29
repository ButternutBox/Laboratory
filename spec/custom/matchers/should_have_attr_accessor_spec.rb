RSpec::Matchers.define :have_attr_accessor do |field|
  match do |object_instance|
    object_instance.respond_to?(field) &&
      object_instance.respond_to?("#{field}=")
  end

  failure_message do |object_inst|
    "expected attr_accessor for #{field} on #{object_inst}"
  end

  failure_message_when_negated do |object_inst|
    "expected attr_accessor for #{field} not to be defined on #{object_inst}"
  end

  description do
    'assert there is an attr_accessor of the given name on the supplied object'
  end
end
