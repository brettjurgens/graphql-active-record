## Set up "Bases" in ActiveRecord
# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  self.verbose = false
  create_table :customers do |t|
    t.column :name, :string
  end

  create_table :products do |t|
    t.column :name, :string
    t.column :customer_id, :integer
  end
end

class Customer < ActiveRecord::Base
  has_one :product
end

class Product < ActiveRecord::Base
  belongs_to :customer
end

p = Product.new(name: "sample")
p.save!

c = Customer.new(name: "Brett")

c.product = p
c.save!
