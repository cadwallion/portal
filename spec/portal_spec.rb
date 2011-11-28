require 'spec_helper'

describe Portal do

  before do
    Portal.conf_file = File.expand_path("./spec/support/test_file.txt")
    Portal.clear_all!
  end

  describe "#add" do
    it "should require a name and host" do
      expect { Portal.add("test", "example.com") }.to_not raise_error
    end

    it "should add the portal to the list by the name" do
      Portal.add("test", "example.com")
      Portal.portals.keys.should include("test")
    end

    it 'should call write_to_conf' do
      Portal.should_receive(:write_to_conf)
      Portal.add('test', 'example.com')
    end

    context 'passing a port' do
      it 'should store the corresponding port' do
        Portal.add('test', 'example.com', :port => 1337)
        Portal.portals['test']['Port'].should == 1337
      end
    end

    context 'passing a user' do
      it 'should store the corresponding user' do
        Portal.add('test', 'example.com', :user => 'test-person')
        Portal.portals['test']['User'].should == 'test-person'
      end
    end
  end

  describe "#write_to_conf" do
    context 'basic host and domain' do
      it 'should only write what is given' do
        expected =  "Host test\n"
        expected << "  HostName example.com\n"
        Portal.add('test', 'example.com')

        content = File.read(Portal.conf_file)
        content.should == expected
      end
    end

    context 'with port and user' do
      it 'should write a line for each additional hash option' do
        expected =  "Host test\n"
        expected << "  HostName example.com\n"
        expected << "  Port 1337\n"
        expected << "  User test-person\n"
        Portal.add('test', 'example.com', port: 1337, user: 'test-person')

        content = File.read(Portal.conf_file)
        content.should == expected
      end
    end
  end

  describe "#remove" do
    context "passed host exists" do
      before do
        Portal.add('test', 'example.com')
      end

      it "should remove the host record" do
        Portal.remove('test')
        Portal.portals.keys.should_not include('test')
      end
    end

    context "passed host does not exist" do
      it "should raise an exception" do
        expect { Portal.remove('foo') }.to raise_error('No portal of that name found.')
      end
    end
  end

  describe "#list" do
    context "with one or more hosts" do
      before do
        Portal.add('test', 'example.com')
        Portal.add('ex1', 'ex1.example.com', port: 42)
      end
      it "should return a list of hosts" do
        expected =  "List of portals: \n\n"
        expected << "test - HostName: example.com\n"
        expected << "ex1 - HostName: ex1.example.com Port: 42\n"
        Portal.list.should == expected
      end
    end

    context "no hosts" do
      it "should return a notification of no hosts" do
        Portal.list.should == "No portals found"
      end
    end
  end
end
