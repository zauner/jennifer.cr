class AddJoinTable20170410221437549 < Jennifer::Migration::Base
  def up
    create(:countries) do |t|
      t.string(:name)
    end
    create_join_table(:contacts, :countries)
    create_join_table(:contacts, :profiles)
  end

  def down
    drop(:countries)
    drop_join_table(:contacts, :countries)
    drop_join_table(:contacts, :profiles)
  end
end
