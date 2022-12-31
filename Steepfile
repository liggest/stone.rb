D = Steep::Diagnostic
#
target :stone do
  signature "sig"

  check "stone.rb"
  check "stone/*.rb"                       # Directory name
  check "test/**/*.rb"
  # check "spec/*.rb"
  check "backend/*.rb"
  # check "Gemfile"                   # File name
  # check "app/models/**/*.rb"        # Glob
  # ignore "lib/templates/*.rb"

  collection_config "rbs_collection.yaml"

  library "pathname", "set", "json"      # Standard libraries
  # library "rspec"
  # library "bundler", "rake", "steep"           # Gems

  # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  # configure_code_diagnostics(Steep::Diagnostic::Ruby.all_error)
  configure_code_diagnostics(D::Ruby.lenient) do |hash|
    # `lenient` diagnostics setting
    hash[D::Ruby::UnsupportedSyntax] = :hint # ignore UnsupportedSyntax
  end
  # configure_code_diagnostics do |hash|             # You can setup everything yourself
  #   hash[D::Ruby::NoMethod] = :information
  # end
end

# target :test do
#   signature "sig", "sig-private"
#
#   check "test"
#
#   # library "pathname", "set"       # Standard libraries
# end
