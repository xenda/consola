# bowling_spec.rb
#require 'bowling'
describe Array, "#first" do
  it "returns the first element" do
    array = [1,2,3]
    array.first.should eq(1)
  end

  it "returns the last element" do
    array = [1,2,3]
    array.last.should eq(1)
  end

end