class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :screen_name
      t.integer :followers_count

      t.timestamps
    end
  end
end
