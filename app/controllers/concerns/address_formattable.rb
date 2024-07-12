module AddressFormattable
  extend ActiveSupport::Concern

  def full_address
    "#{address_params[:street_address]} #{address_params[:city]}, #{address_params[:state]} #{address_params[:zip]}"
  end
end
