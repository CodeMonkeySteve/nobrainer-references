require 'spec_helper'

RSpec.describe NoBrainer::Reference do
  before(:all) do
    class Person
      include NoBrainer::Document
      field :name, type: String
    end

    class Post
      include NoBrainer::Document
      field :title,     type: String
      field :authors,   type: Array.of(Reference.to(Person))
      field :publisher, type: Reference.to(Person)
      index :authors, multi: true
      index :publisher
    end

    NoBrainer.sync_schema
  end

  it "references one" do
    publisher = Person.create!(name: "Marvin")
    post = Post.create!(title: "Stuff", publisher: publisher)

    post.reload
    expect(post.publisher.name).to eq publisher.name
    expect(Post.where(publisher: publisher)).to eq [post]
  end

  it "references many" do
    bob, doug = Person.create!(name: "Bob"), Person.create!(name: "Doug")
    bob_post = Post.create!(title: "Bob Stuff", authors: bob).reload
    doug_post = Post.create!(title: "Doug Stuff", authors: doug).reload
    bd_post = Post.create!(title: "Body & Doug Stuff", authors: [bob, doug]).reload
    db_post = Post.create!(title: "Doug & Bob Stuff", authors: [doug, bob]).reload

    expect(Post.where(:authors.any => bob)).to eq [bob_post, bd_post, db_post]
    expect(Post.where(:authors.any => doug)).to eq [doug_post, bd_post, db_post]
    expect(Post.where(:authors.any.in => [bob, doug])).to eq [bob_post, doug_post, bd_post, db_post]
  end

  it "exception when referenced item is missing" do
    publisher = Person.create!(name: "Marvin")
    post = Post.create!(title: "Stuff", publisher: publisher)

    expect(post.publisher).to eq publisher
    publisher.delete
    post.reload
    expect {
      post.publisher
    }.to raise_error(NoBrainer::Error::MissingAttribute)

    post.publisher = nil
    post.save!
  end
end
