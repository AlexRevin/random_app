class CreatePictureItems < ActiveRecord::Migration
  def change
    create_table :picture_items do |t|
      t.integer :user_id
      t.integer :order
      t.string :url, nil: false
      t.timestamps
    end
    # will be used for re-ordering in compatability mode
    add_index :picture_items, :url
  end
end
