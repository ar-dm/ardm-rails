require 'dm-core'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'
require 'active_model'

begin
  require 'protected_attributes'
rescue LoadError
  module DataMapper
    # In rails ~> 4.0, protected_attributes must be required to use this feature.
    # By requiring it here, we avoid gem load order problems that would cause
    # the module to not exist if protected attributes was loaded after dm-rails.
    #
    # Also this dummy module is inserted to avoid throwing a useless error when the
    # module would otherwise not exist. This is less mysterious than some part of
    # the DataMapper code just going missing because you didn't add
    # protected_attributes to your Gemfile.
    module MassAssignmentSecurity
      extend ::ActiveSupport::Concern

      included do
        raise "Add 'protected_attributes' to your Gemfile to use DataMapper::MassAssignmentSecurity"
      end
    end
  end
else
  module ActiveModel
    module MassAssignmentSecurity
      # Provides a patched version of the Sanitizer used in protected_attributes to
      # handle property and relationship objects as keys. There is no way to inject
      # a custom sanitizer without reimplementing the permission sets.
      Sanitizer.send(Sanitizer.is_a?(Module) ? :module_eval : :class_eval) do
        # Returns all attributes not denied by the authorizer.
        #
        # @param [Class] klass
        #   Model class
        # @param [Hash{Symbol,String,::DataMapper::Property,::DataMapper::Relationship=>Object}] attributes
        #   Names and values of attributes to sanitize.
        # @param [#deny?] authorizer
        #   Usually a ActiveModel::MassAssignmentSecurity::PermissionSet responding to deny?
        # @return [Hash]
        #   Sanitized hash of attributes.
        def sanitize(klass, attributes, authorizer)
          rejected = []
          sanitized_attributes = attributes.reject do |key, value|
            key_name = key.name rescue key
            rejected << key_name if authorizer.deny?(key_name)
          end
          process_removed_attributes(klass, rejected) unless rejected.empty?
          sanitized_attributes
        end
      end
    end
  end

  module DataMapper
    # Include this module into a DataMapper model to enable ActiveModel's mass
    # assignment security.
    #
    # To use second parameter of {#attributes=} make sure to include this module
    # last.
    module MassAssignmentSecurity
      extend ::ActiveSupport::Concern

      include ::ActiveModel::MassAssignmentSecurity

      module ClassMethods
        extend ::ActiveModel::MassAssignmentSecurity::ClassMethods

        def logger
          @logger ||= ::DataMapper.logger
        end
      end

      # Sanitizes the specified +attributes+ according to the defined mass-assignment
      # security rules and calls +super+ with the result.
      #
      # Use either +attr_accessible+ to specify which attributes are allowed to be
      # assigned via {#attributes=}, or +attr_protected+ to specify which attributes
      # are *not* allowed to be assigned via {#attributes=}.
      #
      # +attr_accessible+ and +attr_protected+ are mutually exclusive.
      #
      # @param [Hash{Symbol,String,::DataMapper::Property,::DataMapper::Relationship=>Object}] attributes
      #   Names and values of attributes to sanitize.
      # @param [Boolean] guard_protected_attributes
      #   Determines whether mass-security rules are applied (when +true+) or not.
      # @return [Hash]
      #   Sanitized hash of attributes.
      # @api public
      #
      # @example [Usage]
      #   class User
      #     include DataMapper::Resource
      #     include DataMapper::MassAssignmentSecurity
      #
      #     property :name, String
      #     property :is_admin, Boolean
      #
      #     # Only allow name to be set via #attributes=
      #     attr_accessible :name
      #   end
      #
      #   user = User.new
      #   user.attributes = { :username => 'Phusion', :is_admin => true }
      #   user.username  # => "Phusion"
      #   user.is_admin  # => false
      #
      #   user.send(:attributes=, { :username => 'Phusion', :is_admin => true }, false)
      #   user.is_admin  # => true
      def attributes=(attributes, guard_protected_attributes = true)
        attributes = sanitize_for_mass_assignment(attributes) if guard_protected_attributes
        super(attributes)
      end
    end
  end
end
