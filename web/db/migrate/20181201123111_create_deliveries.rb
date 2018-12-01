class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.boolean :delivered, default: false, null: false

      t.timestamps
    end
  end
end
