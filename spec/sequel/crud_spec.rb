# frozen_string_literal: true

require "English"
require "spec_helper"
require "sequel"

RSpec.describe "Connecting with Sequel" do
  before(:all) do
    @db = Sequel.connect(adapter: "odbc",
                         driver: "/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so",
                         server: "mysql",
                         database: "ruby_odbc",
                         user: @uid,
                         password: @pwd)
  end

  it "run basic operations with Sequel" do
    @db.run("DROP TABLE IF EXISTS test")
    @db.run("CREATE TABLE test (id INT NOT NULL, str VARCHAR(32) NOT NULL)")
    result = @db.fetch("SELECT COUNT(*) AS count FROM information_schema.tables WHERE table_name = 'test'")
    expect(result.first[:count]).to eq(1)

    @db.run("INSERT INTO test (id, str) VALUES (1, 'foo')")
    @db.run("INSERT INTO test (id, str) VALUES (2, 'bar')")

    result = @db.fetch("SELECT * FROM test")
    expect(result.to_a).to eq([{ id: 1, str: "foo" }, { id: 2, str: "bar" }])
  end

  it "fork" do
    # Needed in order to avoid "database already connected" error when using after fork
    Sequel::DATABASES.each(&:disconnect)

    pid = fork do
      @db.run("DROP TABLE IF EXISTS users")
      @db.run("CREATE TABLE users (id INT NOT NULL, name VARCHAR(32) NOT NULL)")

      @db.run("INSERT INTO users (id, name) VALUES (1, 'foo')")
      @db.run("INSERT INTO users (id, name) VALUES (2, 'bar')")

      # ODBC.trace = 2
      result = @db.fetch("SELECT * FROM users")
      expect(result.to_a).to eq([{ id: 1, name: "foo" }, { id: 2, name: "bar" }])
    end

    Process.wait(pid)

    result = @db.fetch("SELECT * FROM users")
    expect(result.to_a).to eq([{ id: 1, name: "foo" }, { id: 2, name: "bar" }])

    expect($CHILD_STATUS.exitstatus).to eq(0)
  end
end
