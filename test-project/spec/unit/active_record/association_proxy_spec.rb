RSpec.describe "DbCharmer::AssociationProxy extending AR::Associations" do
  fixtures :users, :posts

  it "should add proxy? => true method" do
    expect(users(:bill).posts.proxy?).to be(true)
  end

  describe "in has_many associations" do
    before :each do
      @user = users(:bill)
      @posts = @user.posts.all
      Post.switch_connection_to(:logs)
      User.switch_connection_to(:logs)
    end

    after :each do
      Post.switch_connection_to(nil)
      User.switch_connection_to(nil)
    end

    it "should implement on_db proxy" do
      expect(Post.connection).to_not receive(:select_all)
      expect(User.connection).to_not receive(:select_all)

      stub_columns_for_rails31 Post.on_db(:logs).connection
      expect(Post.on_db(:slave01).connection).to receive(:select_all).and_return(@posts.map { |p| p.attributes })
      assert_equal @posts, @user.posts.on_db(:slave01)
    end

    it "on_db should work in prefix mode" do
      expect(Post.connection).to_not receive(:select_all)
      expect(User.connection).to_not receive(:select_all)

      stub_columns_for_rails31 Post.on_db(:logs).connection
      expect(Post.on_db(:slave01).connection).to receive(:select_all).and_return(@posts.map { |p| p.attributes })
      expect(@user.on_db(:slave01).posts).to eq(@posts)
    end

    it "should actually proxy calls to the rails association proxy" do
      Post.switch_connection_to(nil)
      expect(@user.posts.on_db(:slave01).count).to eq(@user.posts.count)
    end

    it "should work with named scopes" do
      Post.switch_connection_to(nil)
      expect(@user.posts.windows_posts.on_db(:slave01).count).to eq(@user.posts.windows_posts.count)
    end

    it "should work with chained named scopes" do
      Post.switch_connection_to(nil)
      expect(@user.posts.windows_posts.dummy_scope.on_db(:slave01).count).to eq(@user.posts.windows_posts.dummy_scope.count)
    end
  end

  describe "in belongs_to associations" do
    before :each do
      @post = posts(:windoze)
      @user = users(:bill)
      User.switch_connection_to(:logs)
      expect(User.connection.object_id).to_not eq(Post.connection.object_id)
    end

    after :each do
      User.switch_connection_to(nil)
    end

    it "should implement on_db proxy" do
      pending
      expect(Post.connection).to_not receive(:select_all)
      expect(User.connection).to_not receive(:select_all)
      expect(User.on_db(:slave01).connection).to receive(:select_all).once.and_return([ @user ])
      expect(@post.user.on_db(:slave01)).to eq(@post.user)
    end

    it "on_db should work in prefix mode" do
      pending
      expect(Post.connection).to_not receive(:select_all)
      expect(User.connection).to_not receive(:select_all)
      expect(User.on_db(:slave01).connection).to receive(:select_all).once.and_return([ @user ])
      expect(@post.on_db(:slave01).user).to eq(@post.user)
    end

    it "should actually proxy calls to the rails association proxy" do
      User.switch_connection_to(nil)
      expect(@post.user.on_db(:slave01)).to eq(@post.user)
    end
  end
end
