require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Yapra do

  it "load class constant from string." do
    Yapra.load_class_constant('Yapra').should == Yapra
  end

  it 'can\'t load constant from invalid name.' do
    lambda {
      Yapra.load_class_constant('_arheiuhri_333***').should be_nil
    }.should raise_error(LoadError)
  end

end
