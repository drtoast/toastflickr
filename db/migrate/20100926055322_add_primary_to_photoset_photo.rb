class AddPrimaryToPhotosetPhoto < ActiveRecord::Migration
  def self.up
    add_column :photoset_photos, :primary, :boolean
  end

  def self.down
    remove_column :photoset_photos, :primary
  end
end
