# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NoBrainer::Document::References do
  class Person
    include NoBrainer::Document
    field :name, type: String
  end

  class Thing
    include NoBrainer::Document
  end

  class Book < Thing
    field :title, type: String
    field :authors, type: Array.of(Reference.to(Person))
    field :publisher, type: Reference.to(Person)
  end

  it "eager loads single reference" do
    publisher = Person.create!(name: Faker::Name.name)
    post = Book.create!(title: Faker::Name.name, publisher: publisher)

    post = Book.where(title: post.title).eager_load(:publisher).first
    expect(Person).not_to receive(:find)
    expect(post.publisher.name).to eq publisher.name
  end

  it "eager loads reference array" do
    bob, doug = Person.create!(name: "Bob"), Person.create!(name: "Doug")
    post = Book.create!(title: Faker::Name.name, authors: [bob, doug])

    post = Book.where(title: post.title).eager_load(:authors).first
    expect(Person).not_to receive(:find)
    expect(post.authors.map(&:name)).to eq [bob, doug].map(&:name)
  end
end
