# frozen_string_literal: true

require "spec_helper"

RSpec.describe ODBC::Driver do
  subject(:driver) do
    ODBC::Driver.new
  end

  describe "#name" do
    it "allows setting the name" do
      new_name = "MySQL"
      driver.name = new_name
      expect(driver.name).to eq(new_name)
    end
  end

  describe "#attrs" do
    it "allows setting the attributes" do
      new_attrs = { "Driver" => "/usr/lib/libmsqldb.so", "Setup" => "/usr/lib/libmsqldb.so" }
      driver.attrs = new_attrs
      expect(driver.attrs).to eq(new_attrs)
    end
  end

  describe ".new" do
    it "initializes with empty name and attrs" do
      new_driver = ODBC::Driver.new
      expect(new_driver.name).to be_nil
      expect(new_driver.attrs).to eq({})
    end
  end
end
