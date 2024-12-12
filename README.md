# NoBrainer References

An alternative to ActiveRecord-style associations using idiomatic Ruby.

## Design

ActiveRecord provides _associations_ between models as a convenient interface to SQL's use of _relations_ between table rows, and NoBrainer matches this functionality.  But they are fundamentally different to the way that Ruby and most programming languages store relationships between models: _references_.

## Installation

Add the Ruby gem to your Gemfile:

    $ bundle add nobrainer-references

## Example

    class Publisher
      include NoBrainer::Document
      field :name, type: String
    end

    class Person
      include NoBrainer::Document
      field :name, type: String
    end

    class Book
      include NoBrainer::Document
      field :title, type: String
      references_many :authors, model: Person
      references_one  :publisher
    end

    douglas_adams = Person.create!(name: "Douglas Adams")
    john_lloyd = Person.create!(name: "John Lloyd")
    publisher = Publisher.create!(name: "Pan Books")
    book = Book.create!(
      title: "The Meaning of Liff",
      authors: [douglas_adams, john_lloyd],
      publisher: publisher
    )

    ...

    book = Book.where(title: "The Meaning of Liff").first
    book.publisher.name         #=> "Pan Books"
    book.authors.map(&:name)    #=> [ "Douglas Adams", "John Lloyd" ]

## How It Works

This gem adds a NoBrainer field type that's a `Reference` to a model of a particular type.  This type acts as a lazy-loading _delegator_, which serializes the referred object by its `id` when saving the model, and then later loads that object when it's dereferenced (or is eager-loaded).

`references_one` and `references_many` are convenience methods for creating fields with the correct types and default names according to convention: 

    references_one  :publisher
    # ... same as ...
    field :publisher, type: Reference.to(Publisher), store_as: 'publishder_id'

    references_many :authors, model: Person
    # ... same as ...
    field :authors, type: Array.of(Reference.to(Person)), store_as: 'author_ids'

It also supports eager-loading of references:

    book = Book.eager_load(:authors, :publisher).where(title: "The Meaning of Liff").first
    book.authors(&:map)   #=> [ "Douglas Adams", "John Lloyd" ]

## Future Plans

* Add a `referenced_by` convenience method for tracking which other models/fields reference this one.  Provides parity with the ActiveRecord `belongs_to`/`has_many` inverse associations.  This would be installed automatically by the `references_one` and `references_many` convenience methods.

* Use reference tracking to implement garbage collection.
