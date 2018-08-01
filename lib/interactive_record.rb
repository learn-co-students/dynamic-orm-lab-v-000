require_relative "../config/environment.rb"
require 'active_support/inflector'
require_relative "./concerns/records"

class InteractiveRecord
  extend Records::ClassMethods
  include Records::InstanceMethods

end