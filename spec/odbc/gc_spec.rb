# frozen_string_literal: true

require "English"
require "spec_helper"

RSpec.describe ODBC::Database, "GC and process fork" do
  # This is the output of the following code when the @connection is not disconnected:
  # ObjAlloc: DBC 0x555556057c20
  # ObjAlloc _new: DBC 0x555556057c20
  # ObjAlloc: ENV 0x5555561fd200
  # ObjAlloc: STMT 0x55555625af70
  # ObjAlloc: STMT 0x555556354c00
  # ObjAlloc: STMT 0x55555625b930
  # ObjAlloc: STMT 0x55555635c490
  # ObjFree: STMT 0x55555625af70
  # WARNING: #<ODBC::Statement:0x7fffe3307d08> was not dropped before garbage collection.
  # ObjFree: STMT 0x555556354c00
  # WARNING: #<ODBC::Statement:0x7fffe3307bc8> was not dropped before garbage collection.
  # ObjFree: STMT 0x55555625b930
  # WARNING: #<ODBC::Statement:0x7fffe3307b78> was not dropped before garbage collection.
  # ObjFree: STMT 0x55555635c490
  # WARNING: #<ODBC::Statement:0x7fffe3307b00> was not dropped before garbage collection.
  # ObjFree: DBC 0x555556057c20
  #
  #
  # When calling disconnect it shows:
  # ODBC::Database forking
  # ObjAlloc: DBC 0x5555561fb770
  # ObjAlloc _new: DBC 0x5555561fb770
  # ObjAlloc: ENV 0x5555561fcbe0
  # ObjAlloc: STMT 0x55555625a620
  # ObjAlloc: STMT 0x555556353b50
  # ObjAlloc: STMT 0x55555625afe0
  # ObjAlloc: STMT 0x55555635b3e0
  # DBC disconnect 0x5555561fb770
  # ObjFree: DBC 0x5555561fb770
  # ObjFree: ENV 0x5555561fcbe0
  # ObjFree: STMT 0x55555625a620
  # ObjFree: STMT 0x555556353b50
  # ObjFree: STMT 0x55555625afe0
  # ObjFree: STMT 0x55555635b3e0
  #
  # With the changes, if disconnect isn't called the Database free should drop all statements:
  # ODBC::Database forking
  # ObjAlloc: DBC 0x5555561fcc20
  # ObjAlloc _new: DBC 0x5555561fcc20
  # ObjAlloc: ENV 0x5555561fd460
  # ObjAlloc: STMT 0x55555625bb60
  # ObjAlloc: STMT 0x555556354dd0
  # ObjAlloc: STMT 0x55555625c520
  # ObjAlloc: STMT 0x55555635c660
  # ObjFree: DBC Dropping all active statements 0x5555561fcc20
  # ObjFree: DBC Dropping statement 0x55555635c660
  # ObjFree: DBC Dropping statement 0x55555625c520
  # ObjFree: DBC Dropping statement 0x555556354dd0
  # ObjFree: DBC Dropping statement 0x55555625bb60
  # ObjFree: DBC 0x5555561fcc20
  # ObjFree: ENV 0x5555561fd460
  # ObjFree: STMT 0x55555625bb60
  # ObjFree: STMT 0x555556354dd0
  # ObjFree: STMT 0x55555625c520
  # ObjFree: STMT 0x55555635c660
  it "ensures that all statements are dropped when the database is disconnected" do
    pid = fork do
      # ODBC.trace = 2
      @connection = ODBC.connect(@dsn, @uid, @pwd)
      @connection.run("DROP TABLE IF EXISTS test_select")
      @connection.run("CREATE TABLE IF NOT EXISTS test_select (id INT NOT NULL, str VARCHAR(32) NOT NULL)")
      @connection.run("INSERT INTO test_select (id, str) VALUES (1, 'foo'), (2, 'bar'), (3, 'FOO'), (4, 'BAR')")
      @statement = @connection.prepare("SELECT id, str FROM test_select ORDER BY id")
      @statement.execute
      expect(@statement.fetch_all.count).to eq(4)
      # expect(@connection.disconnect).to eq(true)
    end
    Process.wait(pid)

    expect($CHILD_STATUS.exitstatus).to eq(0)
  end

  # This should output some warnings:
  # WARNING: #<ODBC::Statement:0x7fffe32f4730> was not dropped before garbage collection.
  it "proactivelly calling GC between statements" do
    # ODBC.trace = 2
    @connection = ODBC.connect(@dsn, @uid, @pwd)
    @connection.run("DROP TABLE IF EXISTS test_select")
    @connection.run("CREATE TABLE IF NOT EXISTS test_select (id INT NOT NULL, str VARCHAR(32) NOT NULL)")
    @connection.run("INSERT INTO test_select (id, str) VALUES (1, 'foo'), (2, 'bar'), (3, 'FOO'), (4, 'BAR')")
    @statement = @connection.prepare("SELECT id, str FROM test_select ORDER BY id")
    @statement.execute
    expect(@statement.fetch_all.count).to eq(4)

    GC.start

    @statement.execute
    expect(@statement.fetch_all.count).to eq(4)
  end
end
