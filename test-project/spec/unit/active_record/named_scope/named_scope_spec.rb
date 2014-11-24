RSpec.describe "Named scopes" do
  fixtures :users, :posts

  before :all do
    Post.switch_connection_to(nil)
    User.switch_connection_to(nil)
  end

  describe "prefixed by on_db" do
    it "should work on the proxy" do
      expect(Post.on_db(:slave01).windows_posts).to eq(Post.windows_posts)
    end

    it "should actually run queries on the specified db" do
      expect(Post.on_db(:slave01).connection).to receive(:select_all).once.and_return([])
      Post.on_db(:slave01).windows_posts.all
      # Post.windows_posts.all
    end

    it "should work with long scope chains" do
      expect(Post.on_db(:slave01).connection).to_not receive(:select_all)
      expect(Post.on_db(:slave01).connection).to receive(:select_value).and_return(5)
      expect(Post.on_db(:slave01).windows_posts.count).to eq(5)
    end

    it "should work with associations" do
      expect(users(:bill).posts.on_db(:slave01).windows_posts.all).to eq(users(:bill).posts.windows_posts)
    end
  end

  describe "postfixed by on_db" do
    it "should work on the proxy" do
      expect(Post.windows_posts.on_db(:slave01)).to eq(Post.windows_posts)
    end

    it "should actually run queries on the specified db" do
      expect(Post.on_db(:slave01).connection.object_id).to_not eq(Post.connection.object_id)
      expect(Post.on_db(:slave01).connection).to receive(:select_all).and_return([])
      Post.windows_posts.on_db(:slave01).all
      Post.windows_posts.all
    end

    it "should work with long scope chains" do
      expect(Post.on_db(:slave01).connection).to_not receive(:select_all)
      expect(Post.on_db(:slave01).connection).to receive(:select_value).and_return(5)
      expect(Post.windows_posts.on_db(:slave01).count).to eq(5)
    end

    it "should work with associations" do
      expect(users(:bill).posts.windows_posts.on_db(:slave01).all).to eq(users(:bill).posts.windows_posts)
    end
  end
end
