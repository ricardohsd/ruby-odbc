# frozen_string_literal: true

require "date"
require_relative "lib/odbc/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-odbc"
  spec.version = ODBC::VERSION
  spec.date = Date.today.to_s
  spec.author = "Christian Werner"
  spec.email = "chw @nospam@ ch-werner.de"
  spec.summary = "ODBC binding for Ruby"
  spec.homepage = "http://www.ch-werner.de/rubyodbc"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  spec.require_paths = ["lib"]

  spec.extensions = ["ext/extconf.rb", "ext/utf8/extconf.rb"]
end
