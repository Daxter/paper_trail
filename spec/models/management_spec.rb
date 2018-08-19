# frozen_string_literal: true

require "spec_helper"

# Add a STI-ish class on-the-fly
class Management < Customer
end

RSpec.describe Management, type: :model, versioning: true do
  it { is_expected.to be_versioned }

  it "utilises the base_class for STI classes having no type column" do
    expect(Management.inheritance_column).to eq("type")
    expect(Management.columns.map(&:name)).not_to include("type")

    # Create, update, and destroy a Management and a Customer
    customer1 = Customer.create(name: "Cust 1")
    customer2 = Management.create(name: "Cust 2")
    customer1.update(name: "Cust 1a")
    customer2.update(name: "Cust 2a")
    customer1.destroy
    customer2.destroy

    # All versions end up with an `item_type` of Customer
    cust_pts = PaperTrail::Version.where(item_type: "Customer")
    mgmt_pts = PaperTrail::Version.where(item_type: "Management")
    expect(cust_pts.count).to eq(6)
    expect(mgmt_pts.count).to eq(0)
  end
end
