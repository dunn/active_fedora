require 'spec_helper'
require 'timeout'

describe "fedora_solr_sync_issues" do
  before :all do
    class ParentThing < ActiveFedora::Base
      has_many :things, :class_name=>'ChildThing', :property=>:is_part_of
    end

    class ChildThing < ActiveFedora::Base
      belongs_to :parent, :class_name=>'ParentThing', :property=>:is_part_of
    end
  end

  after :all do
    Object.send(:remove_const, :ChildThing)
    Object.send(:remove_const, :ParentThing)
  end

  let(:parent) { ParentThing.create }
  subject { ChildThing.create :parent => parent }

  it "should not go into an infinite loop" do
    subject.orm.delete
    parent.reload
    expect(ActiveFedora::Base.logger).to receive(:error).with("Solr and Fedora may be out of sync:\n")
    expect(parent.things).to eq []
  end
end
