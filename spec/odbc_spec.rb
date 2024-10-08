# frozen_string_literal: true

RSpec.describe ODBC do
  it "has a version number" do
    expect(ODBC::VERSION).to be "0.999992"
  end

  it "has Database class" do
    expect(ODBC::Database.new).to respond_to(:drvconnect)
  end
end
