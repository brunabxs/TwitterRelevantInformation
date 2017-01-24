class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.string :uid
      t.integer :retweets_count
      t.integer :likes_count
      t.datetime :creation_date
      t.text :text

      t.timestamps
    end
  end
end
