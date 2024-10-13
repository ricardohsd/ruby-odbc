# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Database CRUD Operations" do
  before(:all) do
    @connection = ODBC.connect(@dsn, @uid, @pwd)
  end

  after(:all) do
    @connection.disconnect
  end

  it "creates a table, inserts records, updates records, deletes records, and drops the table" do
    @connection.run("DROP TABLE IF EXISTS dbcrud")
    @connection.run("CREATE TABLE IF NOT EXISTS dbcrud (id INT NOT NULL, str VARCHAR(32) NOT NULL)")
    result = @connection.run("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'dbcrud'")
    expect(result.fetch[0]).to eq(1)

    q = @connection.run("INSERT INTO dbcrud (id, str) VALUES (1, 'foo')")
    q.run("INSERT INTO dbcrud (id, str) VALUES (2, 'bar')")

    p = @connection.proc("INSERT INTO dbcrud (id, str) VALUES (?, ?)") {}
    p.call(3, "FOO")
    p[4, "BAR"]

    result = @connection.run("SELECT COUNT(*) FROM dbcrud")
    expect(result.fetch[0]).to eq(4)

    result = @connection.run("UPDATE dbcrud SET id=0, str='hoge'")
    expect(result.nrows).to eq(4)

    count = @connection.do("DELETE FROM dbcrud WHERE 1 = 1")
    expect(count).to eq(4)

    count = @connection.do("DELETE FROM dbcrud WHERE 1 = 1")
    expect(count).to eq(0)

    @connection.run("DROP TABLE IF EXISTS dbcrud")
    result = @connection.run("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'dbcrud'")
    expect(result.fetch[0]).to eq(0)
  end
end
