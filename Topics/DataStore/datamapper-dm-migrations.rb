# Using dm-migrations
# https://github.com/datamapper/dm-migrations/tree/master/examples

require 'dm-migrations/migration_runner'

DataMapper.setup(:default, "sqlite3::memory")

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.logger.debug( "Starting Migration" )

migration 1, :create_people_table do
  up do
    create_table :people do
      column :id,   Integer, :serial => true
      column :desc, String
    end
  end

  down do
    drop_table :people
  end
end

migration 2, :make_desc_text do
  up do
    modify_table :people do
      # You currently have to use the underlying DB type here, rather than
      # a DataMapper type
      change_column :desc, 'text'
    end
  end
end

migrate_up!

