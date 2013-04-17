shared_examples_for 'success_controller' do
  it { status_code.should == 200 }
  it { page.find('div.alert-success').should be_visible }
end

%w(create update delete duplicate disable enable).each do |action|
  shared_examples_for "#{action}_success_controller" do
    it_should_behave_like "success_controller"
    it { page.find('div.alert-success').should have_content("#{action.capitalize}d") }
  end
end

shared_examples_for 'failure_controller' do
  it { status_code.should == 200 }
  it { page.find('div.alert-error').should be_visible }
end

