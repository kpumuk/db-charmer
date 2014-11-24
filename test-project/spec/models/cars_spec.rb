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
    expect(Ford.first).to be_valid
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
    expect(Toyota.first).to be_valid
  end
end
