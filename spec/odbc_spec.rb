# frozen_string_literal: true

require "spec_helper"

RSpec.describe ODBC do
  it "has a version number" do
    expect(ODBC::VERSION).to be "0.1-dev"
  end

  it "has Database class" do
    expect(ODBC::Database.new).to respond_to(:drvconnect)
  end

  it "can connect to a database" do
    db = ODBC::Database.connect(@dsn, @uid, @pwd)
    expect(db).to be_a(ODBC::Database)
  end
end
