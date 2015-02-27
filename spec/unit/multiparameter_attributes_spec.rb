require 'spec_helper'
require 'dm-rails/multiparameter_attributes'

# Since multiparameters are a feature of Rails some tests are based on the test
# suite of Rails.
RSpec.describe Rails::DataMapper::MultiparameterAttributes do
  before :all do
    load Pathname(__FILE__).dirname.parent.join('models/topic.rb').expand_path
    load Pathname(__FILE__).dirname.parent.join('models/fake.rb').expand_path
    DataMapper.finalize
    model = ::Rails::DataMapper::Models::Topic
    model.auto_migrate! if model.respond_to?(:auto_migrate!)
  end

  describe '#attributes=' do
    date_inputs = [
      [ 'date',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '6', 'last_read(3i)' => '24' },
        Date.new(2004, 6, 24) ],
      [ 'date with empty year',
        { 'last_read(1i)' => '', 'last_read(2i)' => '6', 'last_read(3i)' => '24' },
        Date.new(1, 6, 24) ],
      [ 'date with empty month',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '', 'last_read(3i)' => '24' },
        Date.new(2004, 1, 24) ],
      [ 'date with empty day',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '6', 'last_read(3i)' => '' },
        Date.new(2004, 6, 1) ],
      [ 'date with empty day and year',
        { 'last_read(1i)' => '', 'last_read(2i)' => '6', 'last_read(3i)' => '' },
        Date.new(1, 6, 1) ],
      [ 'date with empty day and month',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '', 'last_read(3i)' => '' },
        Date.new(2004, 1, 1) ],
      [ 'date with empty year and month',
        { 'last_read(1i)' => '', 'last_read(2i)' => '', 'last_read(3i)' => '24' },
        Date.new(1, 1, 24) ],
      [ 'date with all empty',
        { 'last_read(1i)' => '', 'last_read(2i)' => '', 'last_read(3i)' => '' },
        nil ],
    ]

    date_inputs.each do |(name, attributes, date)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        expect(topic.last_read).to eq(date)
      end
    end

    time_inputs = [
      [ 'time',
        { 'written_on(1i)' => '2004', 'written_on(2i)' => '6', 'written_on(3i)' => '24',
          'written_on(4i)' => '16', 'written_on(5i)' => '24', 'written_on(6i)' => '00' },
        Time.local(2004, 6, 24, 16, 24, 0) ],
      [ 'time with old date',
        { 'written_on(1i)' => '1901', 'written_on(2i)' => '12', 'written_on(3i)' => '31',
          'written_on(4i)' => '23', 'written_on(5i)' => '59', 'written_on(6i)' => '59' },
        Time.local(1901, 12, 31, 23, 59, 59) ],
      [ 'time with all empty',
        { 'written_on(1i)' => '', 'written_on(2i)' => '', 'written_on(3i)' => '',
          'written_on(4i)' => '', 'written_on(5i)' => '', 'written_on(6i)' => '' },
        nil ],
      [ 'time with empty seconds',
        { 'written_on(1i)' => '2004', 'written_on(2i)' => '6', 'written_on(3i)' => '24',
          'written_on(4i)' => '16', 'written_on(5i)' => '24', 'written_on(6i)' => '' },
        Time.local(2004, 6, 24, 16, 24, 0) ],
    ]

    time_inputs.each do |(name, attributes, time)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        expect(topic.written_on).to eq(time)
      end
    end

    date_time_inputs = [
      [ 'datetime',
        { 'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
          'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' },
        DateTime.new(2004, 6, 24, 16, 24, 0) ],
    ]

    date_time_inputs.each do |(name, attributes, time)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        expect(topic.updated_at).to eq(time)
      end
    end

    it 'calls super with merged multiparameters' do
      multiparameter_hash = {
        'composite(1)'  => 'a string',
        'composite(2)'  => '1.5',
        'composite(3i)' => '1.5',
        'composite(4f)' => '1.5',
        'composite(5)'  => '',
        'composite(6i)' => '',
        'composite(7f)' => '',
      }
      attributes = { 'composite' => Object.new }

      expect(::Rails::DataMapper::Models::Composite).
        to receive(:new).
        with('a string', '1.5', '1.5'.to_i, '1.5'.to_f).
        and_return(attributes['composite'])

      composite_property = double(::DataMapper::Property)
      allow(composite_property).to receive(:primitive).and_return(::Rails::DataMapper::Models::Composite)

      resource = ::Rails::DataMapper::Models::Fake.new
      allow(resource).to receive(:properties).and_return('composite' => composite_property)

      expect(resource).to receive(:_super_attributes=).with(attributes)

      resource.attributes = multiparameter_hash
    end

    it 'raises exception on failure' do
      multiparameter_hash = { 'composite(1)'  => 'a string' }
      attributes = { 'composite' => Object.new }

      composite_exception = StandardError.new('foo')
      expect(::Rails::DataMapper::Models::Composite).
        to receive(:new).with('a string').and_raise(composite_exception)

      composite_property = double(::DataMapper::Property)
      allow(composite_property).to receive(:primitive).and_return(::Rails::DataMapper::Models::Composite)

      resource = ::Rails::DataMapper::Models::Fake.new
      allow(resource).to receive(:properties).and_return('composite' => composite_property)

      expect { resource.attributes = multiparameter_hash }.
        to raise_error(::Rails::DataMapper::MultiparameterAssignmentErrors) { |ex|
          expect(ex.errors.size).to eq(1)

          error = ex.errors[0]
          expect(error.attribute).to eq('composite')
          expect(error.values).to eq(['a string'])
          expect(error.exception).to eq(composite_exception)
        }
    end
  end

  describe 'new' do
    it "merges multiparameters" do
      attributes = {
        'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
        'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' }

      topic = ::Rails::DataMapper::Models::Topic.new(attributes)
      expect(topic.updated_at).to eq(DateTime.new(2004, 6, 24, 16, 24, 0))
    end
  end

  describe 'create' do
    it "merges multiparameters" do
      attributes = {
        'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
        'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' }

      topic = ::Rails::DataMapper::Models::Topic.create(attributes)
      expect(topic.updated_at).to eq(DateTime.new(2004, 6, 24, 16, 24, 0))
    end
  end
end
