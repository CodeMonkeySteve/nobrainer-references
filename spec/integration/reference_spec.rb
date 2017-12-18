require 'spec_helper'

RSpec.describe NoBrainer::Reference do
  before(:all) do
    class Person
      include NoBrainer::Document
      field :name, type: String
    end

    class Post
      include NoBrainer::Document
      field :title, type: String
      field :published, type: Boolean
      field :authors, type: Array.of(Reference.to(Person))
      field :publisher, type: Reference.to(Person)
    end
  end

  it "references one" do
    publisher = Person.create!(name: "Marvin")
    post = Post.create!(title: "Stuff", publisher: publisher)
    expect(post.reload.publisher.name).to eq publisher.name
  end

  it "references many" do
    authors = [ Person.create!(name: "Bob"), Person.create!(name: "Doug") ]
    post = Post.create!(title: "Stuff", authors: authors)
    expect(post.reload.authors.map(&:name)).to eq authors.map(&:name)
  end
end
