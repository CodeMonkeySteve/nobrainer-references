require 'spec_helper'

RSpec.describe NoBrainer::Array do
  before do
    class Post
      include NoBrainer::Document
      field :tags, type: Array.of(String)
    end
  end

  it "validates type" do
    post = Post.new(tags: %w(foo bar baaz))
    expect(post).to be_valid

    post = Post.new(tags: [1, 2.3, /regex/])
    expect(post).not_to be_valid
    expect(post.errors.keys).to eq %i(tags)
    expect(post.errors[:tags]).to eq ["should be a string/array"]
  end
end
