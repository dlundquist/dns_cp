class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string :name
      t.string :master
      t.text :key

      t.timestamps
    end
  end

  def self.down
    drop_table :zones
  end
end
