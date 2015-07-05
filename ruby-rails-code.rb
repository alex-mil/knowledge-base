##############################
# ActiveRecord Optimizations #
##############################
# 1. Use empty? or any? instead of blank? or present?.
# 2. Never use map on active record relations, use pluck instead.
# 3. If you're using pluck to pass values to a where use select instead.
1.
# will load the entire array, then check to see if the array is empty.
User.where(screen_name: ['user1','user2']).blank?
  vs.
# asks the database for a count, and checks to see if that count is zero or not.
User.where(screen_name: ['user1','user2').empty?
2.
# load the entire array, then iterate to collect the screen_names.
User.where(email: ['jane@example.com', 'john@example.com']).map(&:screen_name)
  vs.
# asks the database for exactly what it needs and returns an array of just those items.
User.where(email: ['jane@example.com', 'john@example.com']).pluck(:screen_name)
3.
# Using `select` with a `where`
emails =  ['jane@example.com', 'john@example.com']
User.where(screen_name: User.where(email: emails).select(:screen_name)).empty?
# SELECT COUNT(*) FROM "users" WHERE "users"."screen_name" IN (
#   SELECT "users"."screen_name" FROM "users" WHERE "users"."email" IN ('jane@example.com','john@example.com')
# )

#######################
# Enumerators of Ruby #
#######################
1. [Animal.new, Animal.new, Human.new, Human.new, Animal.new].partition { |c| c.is_animal? } # => Array of Arrays
2. [Person.new("Peter"), Person.new("Meg"), Person.new("Louis")].each_with_object("Hello") do |person, greeter|
  person.greet(greeter) # Hello Peter, Hello Meg, Hello Louis
end
3. [Product.new(100), Product.new(120), Product.new(1000)].max_by(&:price) 
   # => #<Product:0x007fb019861228 @price=1000>
4. [Product.new(100), Product.new(120), Product.new(1000)].minmax_by(&:price)
   # => [#<Product:0x007fb01887a418 @price=100>, #<Product:0x007fb01887a3c8 @price=1000>]
5. [Person.new, Person.new, Cop.new, Person.new].take_while(&:can_be_robbed?) # can_be_robbed? is a method
   # =>[#<Person:0x007fa21a848848>, #<Person:0x007fa21a848820>]

###################################
# Split a list into head and tail #
###################################
# list could be: [], ['a'], ['a', 'b', '1', 'd'] or even not an array
first, *rest = *list

#############################
# Decorators and Presenters #
#############################
# app/models/user.rb
class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :age
  
  # ...
  # many lines of code
  # ...
end

# app/presenters/user_presenter.rb
require 'delegate'
class UserPresenter < SimpleDelegator
  def full_name
    "#{entity.first_name} #{entity.last_name}"
  end
  
  def test
  end
  
  # Returns ref to the object we're decorating
  def entity
    __getobj__
  end
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def show
    user_to_show = User.find(params[:id])
    @user = UserPresenter.new(user_to_show)
  end
end

#################################
# List all available rake tasks #
#################################
rake -P # e.g. rake middleware

##########################
# Organizing stylesheets #
##########################
# Base styles
@import "base/mixins"
@import "base/reset"
@import "base/grids"
@import "base/spaces"
@import "base/helper"

# Layout specific styles
@import "application/typography"
@import "application/layout"

# Objects
@import "application/objects/buttons"
@import "application/objects/inputs"
.......................

# Modules
@import "application/modules/dashboard"
@import "application/modules/profile"
.......................
stylesheets
  ├── global
  │   ├── mixins.sass
  │   ├── reset.sass
  │   ├── grids.sass
  │   ├── spaces.sass
  │   └── helpers.scss
  ├── application.sass
  ├── application
  │   ├── layout.sass
  │   ├── typography.sass
  │   ├── components
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
