class AddAdminAuthorizationTousers < ActiveRecord::Migration
  def change
    add_column :users, :admin_authorization, :boolean
  end
end
