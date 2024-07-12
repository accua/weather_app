require 'rails_helper'

RSpec.describe AddressForm do
  subject(:form) { described_class.new(valid_attributes) }

  let(:valid_attributes) do
    {
      street_address: '123 Main St',
      city: 'Anytown',
      state: 'NY',
      zip: '12345'
    }
  end

  it { should validate_presence_of(:street_address) }
  it { should validate_length_of(:street_address).is_at_least(3) }

  it { should validate_presence_of(:city) }
  it { should validate_length_of(:city).is_at_least(2) }

  it { should validate_presence_of(:state) }
  it { should validate_length_of(:state).is_at_least(2).is_at_most(13) }
  it { should allow_value('NY').for(:state) }

  it { should validate_presence_of(:zip) }
  it { should allow_value('12345').for(:zip) }
  it { should_not allow_value('1234').for(:zip) }
  it { should_not allow_value('123456').for(:zip) }

  describe 'validations' do
    context 'when all attributes are valid' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid when street_address is too short' do
        form.street_address = 'a'
        expect(form).to be_invalid
        expect(form.errors[:street_address]).to include('is too short (minimum is 3 characters)')
      end

      it 'is invalid when city is too short' do
        form.city = 'a'
        expect(form).to be_invalid
        expect(form.errors[:city]).to include('is too short (minimum is 2 characters)')
      end

      it 'is invalid when state is too short' do
        form.state = 'N'
        expect(form).to be_invalid
        expect(form.errors[:state]).to include('is too short (minimum is 2 characters)')
      end

      it 'is invalid when zip is not five digits' do
        form.zip = '1234'
        expect(form).to be_invalid
        expect(form.errors[:zip]).to include('must be a 5-digit number')
      end
    end
  end
end
