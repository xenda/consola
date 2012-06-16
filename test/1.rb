describe "getting to know you" do
  it "we expected to receive a String" do
    value = $value
    value.should be_an_instance_of String
  end
end