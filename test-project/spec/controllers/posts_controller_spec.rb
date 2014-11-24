RSpec.describe PostsController do
  fixtures :posts

  # Delete these examples and add some real ones
  it "should support db_charmer readonly actions method" do
    expect(PostsController.respond_to?(:force_slave_reads)).to be(true)
  end

  it "index action should force slave reads" do
    expect(PostsController.force_slave_reads_action?(:index)).to be(true)
  end

  it "create action should not force slave reads" do
    expect(PostsController.force_slave_reads_action?(:create)).to be(false)
  end

  describe "GET 'index'" do
    context "slave reads enforcing (action is listed in :only)" do
      it "should enable enforcing" do
        get 'index'
        expect(controller.force_slave_reads?).to be(true)
      end

      it "should actually force slave reads" do
        expect(Post.connection).to_not receive(:select_value) # no counts
        expect(Post.connection).to_not receive(:select_all) # no finds
        expect(Post.on_slave.connection).to receive(:select_value).and_return(1)
        get 'index'
      end
    end
  end

  describe "GET 'show'" do
    context "slave reads enforcing (action is listed in :only)" do
      it "should enable enforcing" do
        get 'show', id: Post.first.id
        expect(controller.force_slave_reads?).to be(true)
      end

      it "should actually force slave reads" do
        post = Post.first
        expect(Post.connection).to_not receive(:select_value) # no counts
        expect(Post.connection).to_not receive(:select_all) # no finds
        expect(Post.on_slave.connection).to receive(:select_value).and_return(1)
        expect(Post.on_slave.connection).to receive(:select_all).and_return([post.attributes])
        get 'show', id: post.id
      end
    end
  end

  describe "GET 'new'" do
    context "slave reads enforcing (action is listed in :except)" do
      it "should not enable enforcing" do
        get 'new'
        expect(controller.force_slave_reads?).to be(false)
      end

      it "should not do any actual enforcing" do
        expect(Post.connection).to receive(:select_value).and_return(0) # count
        expect(Post.on_slave.connection).to_not receive(:select_value) # no counts
        expect(Post.on_slave.connection).to_not receive(:select_all) # no selects
        get 'new'
      end
    end
  end

  describe "GET 'create'" do
    it "should redirect to post url upon successful completion" do
      get 'create', post: { title: 'xxx', user_id: 1 }
      expect(response).to redirect_to(post_url(Post.last))
    end

    it "should create a Post record" do
      expect {
        get 'create', post: { title: 'xxx', user_id: 1 }
      }.to change { Post.count }.by(+1)
    end

    context "slave reads enforcing (action is not listed in force_slave_reads params)" do
      it "should not enable enforcing" do
        get 'create'
        expect(controller.force_slave_reads?).to_not be(true)
      end

      it "should not do any actual enforcing" do
        expect(Post.on_slave.connection).to_not receive(:select_value)
        expect(Post.connection).to receive(:select_value).once.and_return(1)
        get 'create'
      end
    end
  end

  describe "GET 'destroy'" do
    it "should redurect to index upon completion" do
      get 'destroy', id: Post.first.id
      expect(response).to redirect_to(action: :index)
    end

    it "should delete a record" do
      expect {
        get 'destroy', id: Post.first.id
      }.to change { Post.count }.by(-1)
    end
  end
end
