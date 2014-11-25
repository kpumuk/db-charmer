RSpec.describe Ford, "STI model" do
  before :each do
    @valid_attributes = {
      license: "FFGH-9134",
    }
  end

  it "should create a new instance given valid attributes" do
    Ford.create!(@valid_attributes)
  end

  it "should properly handle slave find calls" do
    Ford.create!(@valid_attributes)
    expect(Ford.last).to be_valid
  end
end

RSpec.describe Toyota, "STI model" do
  before :each do
    @valid_attributes = {
      license: "TFGH-9134"
    }
  end

  it "should create a new instance given valid attributes" do
    Toyota.create!(@valid_attributes)
  end

  it "should properly handle slave find calls" do
    Toyota.create!(@valid_attributes)
    expect(Toyota.last).to be_valid
  end
end
