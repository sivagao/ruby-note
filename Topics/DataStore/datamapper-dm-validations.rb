# Using dm-validations
# https://github.com/datamapper/dm-validations


# Specifying Model Validations
require "dm-core"
require "dm-validations"

# validation methods with properties as params
# auto-validations. as autovalidation options
class ProgrammingLanguage
    include DateMapper::Resource

    property :name, String

    validates_presence_of :name

    #property :name, String, :required => true
end

#Validating
#DataMapper validations, when included, 
#alter the default save/create/update process for a model.
#manually validate a resource using the valid? method

# Working with validation error
my_account = Account.new(:name => "Jose")
if my_account.save
  # my_account is valid and has been saved
else
  my_account.errors.each do |e|
    puts e
  end
end

# Contextual Validations
# which provides a means of grouping your validations into contexts.
# This enables you to run different sets of validations when you need it. For instance, 
# the same model may not only behave differently when initially saved or saved on update, 
# but also require special validation sets for publishing, exporting, importing and so on.

# some validation after with a when option, which indicate the context
class ProgrammingLanguage

  include DataMapper::Resource

  property :name, String

  def ensure_allows_manual_memory_management
    # ...
  end

  def ensure_allows_optional_parentheses
    # ...
  end

  validates_presence_of :name
  validates_with_method :ensure_allows_optional_parentheses,     :when => [:implementing_a_dsl]
  validates_with_method :ensure_allows_manual_memory_management, :when => [:doing_system_programming]
end

# using context Each context causes different set of validations to be triggered. 
@ruby.valid?(:implementing_a_dsl)       # => true
@ruby.valid?(:doing_system_programming) # => false

@c.valid?(:implementing_a_dsl)       # => false
@c.valid?(:doing_system_programming) # => true


class Book

  include ::DataMapper::Resource

  property :id,           Serial
  property :name,         String

  property :agreed_title, String
  property :finished_toc, Boolean

  # used in all contexts, including default
  validates_presence_of :name,         :when => [:default, :sending_to_print]
  validates_presence_of :agreed_title, :when => [:sending_to_print]

  validates_with_block :toc, :when => [:sending_to_print] do
    if self.finished_toc
      [true]
    else
      [false, "TOC must be finalized before you send a book to print"]
    end
  end
end