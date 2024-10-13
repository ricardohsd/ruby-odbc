# frozen_string_literal: true

require "spec_helper"

RSpec.describe ODBC::Statement, "select queries" do
  before(:all) do
    @connection = ODBC.connect(@dsn, @uid, @pwd)
    @connection.run("DROP TABLE IF EXISTS test_select")
    @connection.run("CREATE TABLE test_select (id INT NOT NULL, str VARCHAR(32) NOT NULL)")
    @connection.run("INSERT INTO test_select (id, str) VALUES (1, 'foo'), (2, 'bar'), (3, 'FOO'), (4, 'BAR')")
    @statement = @connection.prepare("SELECT id, str FROM test_select ORDER BY id")
    @statement.execute
  end

  after(:all) do
    @statement.run("DROP TABLE IF EXISTS test_select")
    @statement.close
    @connection.disconnect
  end

  around(:each) do |example|
    @statement.execute
    example.run
    @statement.close
  end

  it "checks column names" do
    expect(@statement.column(0).name.upcase).to eq("ID")
    expect(@statement.column(1).name.upcase).to eq("STR")
  end

  it "fetches each row" do
    expect(@statement.fetch).to eq([1, "foo"])
    expect(@statement.fetch).to eq([2, "bar"])
    expect(@statement.fetch).to eq([3, "FOO"])
    expect(@statement.fetch).to eq([4, "BAR"])
    expect(@statement.fetch).to be_nil
  end

  it "fetches all entries" do
    expect(@statement.execute.entries).to eq([[1, "foo"], [2, "bar"], [3, "FOO"], [4, "BAR"]])
  end

  it "fetches all rows using fetch_all" do
    expect(@statement.execute.fetch_all).to eq([[1, "foo"], [2, "bar"], [3, "FOO"], [4, "BAR"]])
  end

  it "fetches multiple rows with fetch_many" do
    expect(@statement.fetch_many(2)).to eq([[1, "foo"], [2, "bar"]])
    expect(@statement.fetch_many(3)).to eq([[3, "FOO"], [4, "BAR"]])
    expect(@statement.fetch_many(99)).to be_nil
  end

  it "executes block and collects entries" do
    a = []
    @statement.execute { |r| a = r.entries }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows" do
    a = []
    @statement.execute.each { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as hashes" do
    a = []
    @statement.execute.each_hash { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as hashes with table names" do
    a = []
    @statement.execute.each_hash(true) { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as symbols" do
    a = []
    @statement.execute.each_hash(key: :Symbol) { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as symbols with table names" do
    a = []
    @statement.execute.each_hash(key: :Symbol, table_names: true) { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as strings without table names" do
    a = []
    @statement.execute.each_hash(key: :String, table_names: false) { |r| a.push(r) }
    expect(a.size).to eq(4)
  end

  it "executes block and collects rows as fixnums without table names" do
    a = []
    @statement.execute.each_hash(key: :Fixnum, table_names: false) { |r| a.push(r) }
    expect(a.size).to eq(4)
  end
end
