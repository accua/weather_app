class AddressForm
  include ActiveModel::Model

  attr_accessor :street_address, :city, :state, :zip

  validates :street_address, presence: true, length: { minimum: 3 }
  validates :city, presence: true, length: { minimum: 2 }
  validates :state, presence: true, length: { minimum: 2, maximum: 13 }
  validates :zip, presence: true, format: { with: /\A\d{5}\z/, message: 'must be a 5-digit number' }

  validate :no_special_characters, if: -> { street_address.present? || city.present? }

  private

  def no_special_characters
    special_characters = %r{[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?]+}

    return unless street_address.to_s.match?(special_characters) || city.to_s.match?(special_characters)

    errors.add(:base, 'Address fields should not contain special characters')
  end
end
