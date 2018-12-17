class Delivery < ApplicationRecord
  has_many :orders, dependent: :restrict_with_exception

  def as_json(args)
    super.merge({
      location: orders.first.location,
      commodities: orders.group_by(&:commodity).map do |commodity, orders|
        "#{commodity}: #{orders.map(&:quantity).map(&:to_i).sum()}"
      end
    })
  end
end
