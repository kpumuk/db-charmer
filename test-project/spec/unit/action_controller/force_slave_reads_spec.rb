class BlahController < ActionController::Base; end

RSpec.describe ActionController, "with force_slave_reads extension" do
  before :each do
    BlahController.force_slave_reads({}) # cleanup status
  end

  it "should not force slave reads when there are no actions defined as forced" do
    expect(BlahController.force_slave_reads_action?(:index)).to be(false)
  end

  it "should force slave reads for :only actions" do
    BlahController.force_slave_reads only: :index
    expect(BlahController.force_slave_reads_action?(:index)).to be(true)
  end

  it "should not force slave reads for non-listed actions when there is :only parameter" do
    BlahController.force_slave_reads only: :index
    expect(BlahController.force_slave_reads_action?(:show)).to be(false)
  end

  it "should not force slave reads for :except actions" do
    BlahController.force_slave_reads except: :delete
    expect(BlahController.force_slave_reads_action?(:delete)).to be(false)
  end

  it "should force slave reads for non-listed actions when there is :except parameter" do
    BlahController.force_slave_reads except: :delete
    expect(BlahController.force_slave_reads_action?(:index)).to be(true)
  end

  it "should not force slave reads for actions listed in both :except and :only lists" do
    BlahController.force_slave_reads only: :delete, except: :delete
    expect(BlahController.force_slave_reads_action?(:delete)).to be(false)
  end

  it "should not force slave reads for non-listed actions when there are :except and :only lists present" do
    BlahController.force_slave_reads only: :index, except: :delete
    expect(BlahController.force_slave_reads_action?(:show)).to be(false)
  end
end
