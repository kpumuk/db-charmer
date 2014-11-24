RSpec.describe "ActiveRecord in finder methods" do
  fixtures :categories, :users, :posts, :categories_posts, :avatars

  before :each do
    Post.db_magic connection: nil
    User.db_magic connection: nil
  end

  after :each do
    Post.db_magic(Post::DB_MAGIC_DEFAULT_PARAMS)
  end

  it "should switch all belongs_to association connections when :include is used" do
    expect(User.connection).to_not receive(:select_all)
    Post.on_db(:slave01).all(include: :user)
  end

  it "should switch all has_many association connections when :include is used" do
    expect(Post.connection).to_not receive(:select_all)
    User.on_db(:slave01).all(include: :posts)
  end

  it "should switch all has_one association connections when :include is used" do
    expect(Avatar.connection).to_not receive(:select_all)
    User.on_db(:slave01).all(include: :avatar)
  end

  it "should switch all has_and_belongs_to_many association connections when :include is used" do
    expect(Post.connection).to_not receive(:select_all)
    Category.on_db(:slave01).all(include: :posts)
  end

  #-------------------------------------------------------------------------------------------
  it "should not switch assocations when called on a top-level connection" do
    expect(User.connection).to receive(:select_all).and_return([])
    Post.all(include: :user)
  end

  it "should not switch connection when association model and main model are on different servers" do
    expect(LogRecord.connection).to receive(:select_all).and_return([])
    User.on_db(:slave01).all(include: :log_records)
  end
end
