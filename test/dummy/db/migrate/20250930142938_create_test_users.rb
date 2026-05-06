class CreateTestUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps
      t.boolean :admin, :default => false
      t.boolean :guest, :default => false
      t.string  :locale, :default => 'en-US'
      t.string  :name
      t.string  :gender
      t.string  :mugshot
      t.string  :link

    end
  end

  def self.down
    drop_table :users
  end

end # class CreateTestUsers
