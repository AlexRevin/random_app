class CreatePicture < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.integer :user_id
      t.string :first_pic
      t.string :urls

      t.timestamps
    end
  end
end
