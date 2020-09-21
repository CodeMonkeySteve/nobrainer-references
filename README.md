# NoBrainer References

An alternative to ActiveRecord-style associations using idiomatic Ruby.

## Design

ActiveRecord provides _associations_ between models as a convenient interface to SQL's use of _relations_ between table rows.  But they are fundamentally different to the way that Ruby (and pretty much all other pro)    


## Installation

Include in your Gemfile:

    gem 'nobrainer-references', git: 'https://github.com/CodeMonkeySteve/nobrainer-references.git'


## Usage

### One-to-one

This gem adds a NoBrainer field type that's a `Reference` to a model of a particular type.  This type acts as a lazy-loading _delegator_, which serializes the referred object by its `id` when saving the model, and then later loads that object when it's accessed.

    class Publisher
      include Mongoid::Document
      field :name, type: String
    end

    class Book
      include Mongoid::Document
      field :title, type: String
      field :publisher, type: Reference.to(Person)
    end

    editor = Person.create!(name: "Stephen Hawking")
    book = Book.create!(title: "A Brief History of Time", author: author)

    book.reload
    book.editor.name # => "Stephen Hawking"

### One-to-many

This gem also adds a `TypedArray` field type with proper serialization support and type checking.  This can be combined with the `Reference` type to 

