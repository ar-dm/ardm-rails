require 'spec_helper'

begin
  require 'protected_attributes'
rescue LoadError
end

# Unfortunately, the only way to test both branches of this code is to
#   bundle --without protected_attributes
# and then run the spec again.
if defined?(ActiveModel::MassAssignmentSecurity)
  # Because mass-assignment security is based on ActiveModel we just have to
  # ensure that ActiveModel is called.
  RSpec.describe DataMapper::MassAssignmentSecurity do
    before :all do
      class Fake
        super_module = Module.new do
          def _super_attributes=(*args)
          end

          def attributes=(*args)
            self.send(:_super_attributes=, *args)
          end
        end
        include super_module

        include ::DataMapper::MassAssignmentSecurity
      end
    end

    describe '#attributes=' do
      it 'calls super with sanitized attributes' do
        attributes = { :name => 'John', :is_admin => true }
        sanitized_attributes = { :name => 'John' }
        model = Fake.new
        model.should_receive(:sanitize_for_mass_assignment).with(attributes).and_return(sanitized_attributes)
        model.should_receive(:_super_attributes=).with(sanitized_attributes)

        model.attributes = attributes
      end

      it 'skips sanitation when called with true' do
        attributes = { :name => 'John', :is_admin => true }
        sanitized_attributes = { :name => 'John' }
        model = Fake.new
        model.should_receive(:_super_attributes=).with(attributes)

        model.send(:attributes=, attributes, true)
      end
    end
  end
else
  RSpec.describe DataMapper::MassAssignmentSecurity do
    it "raises if the DataMapper::MassAssignmentSecurity is included" do
      expect {
        class Fake
          include ::DataMapper::MassAssignmentSecurity
        end
      }.to raise_error("Add 'protected_attributes' to your Gemfile to use DataMapper::MassAssignmentSecurity")
    end
  end
end
