class CreateSoundclouds < ActiveRecord::Migration
  def change
    create_table :soundclouds do |t|
      t.string :title
      t.integer :soundcloud_id

      t.timestamps
    end
  end
end
