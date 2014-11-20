##########################
# Organizing stylesheets #
##########################
// Base styles
@import "base/mixins"
@import "base/reset"
@import "base/grids"
@import "base/spaces"
@import "base/helper"

// Layout specific styles
@import "application/typography"
@import "application/layout"

// Objects
@import "application/objects/buttons"
@import "application/objects/inputs"
.......................

// Modules
@import "application/modules/dashboard"
@import "application/modules/profile"
.......................
stylesheets
  ├── base
  │   ├── mixins.sass
  │   ├── reset.sass
  │   ├── grids.sass
  │   ├── spaces.sass
  │   └── helpers.scss
  ├── application.sass
  ├── application
  │   ├── layout.sass
  │   ├── typography.sass
  │   ├── objects
  │   |   ├── buttons.sass
  │   |   ├── inputs.sass
  |   |   └── ..........
  │   ├── modules
  │   |   ├── profile.sass
  │   |   ├── dashboard.sass
  |   |   └── ..........
  │   └── responsive
  │       ├── tablet.sass
  │       ├── mobile.sass
  |       └── ..........
  └── shared
      ├── popup.sass
      ├── markdown.sass
      └── ..........
      
######################
# with_options block #
######################
class User < ActiveRecord::Base
 with_options if: :is_admin? do |admin|
    admin.validates :name, presence: true
    admin.validates :email, presence: true
  end
end

# or in Rails 4.2
class User < ActiveRecord::Base
 with_options if: :is_admin?
    validates :name, presence: true
    validates :email, presence: true
  end
end

##################################
# Early return from a controller #
##################################
class Controller
  def show
    verify_order; return if performed? # test whether render or redirect already happened
    # even more code over there ...
  end

  private

  def verify_order
    unless @order.awaiting_payment? || @order.failed?
      redirect_to edit_order_path(@order) and return
    end

    if invalid_order?
      redirect_to tickets_path(@order) and return
    end
  end
end

##########################################
# Fix params attributes for nested model #
##########################################
class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end
...
# in the Posts controller
def update
  params[:comments_attributes] = params.delete(:comments) if params.has_key? :comments
  # call to update_attributes and whatever else you need to do
 end
 # in case of BackboneJS it could be done on client side as well
 # in your Post model
toJSON: ->
  attrs = _.clone(@attributes)
  attrs.comments_attributes = _.clone(@attributes.comments)
  delete attrs.comments
  attrs
  
###############################################
# Find duplicate records for specific columns #
###############################################
class User < ActiveRecord::Base
  include FindDuplicate
end

User.find_duplicates(:token)
User.duplicate?(:token)
User.duplicates(:token)
User.duplicates_with_self(:token)

# module code
module FindDuplicate
  extend ActiveSupport::Concern
  
  def duplicate?(field)
    duplicates_with_self(field).count > 1
  end

  def duplicates(field)
    duplicates_with_self(field).where('id <> ?', id)
  end

  def duplicates_with_self(field)
    self.class.unscoped.where(field => self[field])
  end
  
  module ClassMethods
    def find_duplicates(field)
      field = field.to_sym
      where field => User.select(['count(*)', field]).group(field).having('count(*) > 1').map(&field)
    end
  end
end

####################################
# Search and Filter Rails Models   #
####################################
# app/models/concerns/filterable.rb
module Filterable
  extend ActiveSupport::Concern

  # Call the class methods with the same name as the keys in <tt>filtering_params</tt>
  # with their associated values. Most useful for calling named scopes from 
  # URL params. Make sure you don't pass stuff directly from the web without 
  # whitelisting only the params you care about first!
  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil) # creates an anonymous scope
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end
  end
end

# app/models/product.rb
class Product
  include Filterable
  ...
end

# app/controllers/product_controller.rb
def index
  @products = Product.filter(params.slice(:status, :location, :starts_with))
end


#######################################
# Rails url_for and namespaced models #
#######################################
# app/models/m/user.rb
module M
  class User < ActiveRecord::Base
  end
end

module M
  def self.use_relative_model_naming?
    true
  end
end

# app/views/users/index.html.haml
url_for(@user)


##########################
# Ruby Enumerable#inject #
##########################
def sum(arr)
  arr.inject(:+)
end

sum([1,2,3]) #=> 6

def count_of_words(str)
  str.split(' ').inject(Hash.new(0)) do |count_hash, word|
    count_hash[word] += 1
    count_hash
  end
end

count_of_words('ruby is awesome and ruby is great')
# => {"ruby"=>2, "is"=>2, "awesome"=>1, "and"=>1, "great"=>1}


####################
# Ruby Memoization #
####################
def current_user
  @current_user ||= if session[:user_id]
                      User.find(session[:user_id])
                    else
                      User.new(guest: true)
                    end
end

def current_advertising_balance
  @current_advertising_balance ||= begin
    amount_owed = Invoice.procces.something(:complicated) + OtherThing
    amount_paid = Payment.procces.something(:complicated) + OtherThing
    amount_owed - amount_paid
  rescue
    0.0
  ensure
    Advertiser.mark_that_we_calculated_balance
  end
end

def foo
  return @foo if defined?(@foo)

  puts "hit"
  sleep 5
  @foo = false
end

foo() # => "hit"
foo() # => nothing printed

class A
  def initialize
    @results = {}
  end

  def expensive_operation(p1)
    return @results[p1] unless @results[p1].nil?

    @results[p1] = begin
                     puts "hit"
                     sleep 5
                   end
  end
end

a = A.new
a.expensive_operation('a') # => "hit"
a.expensive_operation('a') # => nothing printed


################################
# Dependency Injection in Ruby #
################################
class Hacker
  def self.build(layout = 'us')
    new(Keyboard.new(:layout => layout))
  end

  def initialize(keyboard)
    @keyboard = keyboard
  end
  
  ...
end

# we can create a hacker instance with very little effort
Hacker.build('us')

# there might be a case we already have a keyboard, that's gonna work too
Hacker.new(keyboard_we_already_had)

# how to test
describe Hacker do
  # let's say keyboard is a heavy dependency so we just want to mock it here
  let(:keyboard) { mock('keyboard') }

  it 'writes awesome ruby code' do
    hacker = Hacker.new(keyboard)

    # some expectations
  end
end

#######################################
# Migration to rename database column #
#######################################
rails g migration FixColumnName

class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :table_name, :old_column, :new_column
  end
end

class FixColumnNames < ActiveRecord::Migration
  def change
    change_table :table_name do |t|
      t.rename :old_column1, :new_column1
      t.rename :old_column2, :new_column2
      ...
    end
  end
end
