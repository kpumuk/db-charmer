RSpec.describe Comment do
  fixtures :comments, :avatars, :posts, :users

  describe "preload polymorphic association" do
    subject do
      lambda {
        Comment.includes(:commentable).all
      }
    end

    it { should_not raise_error }
  end
end
