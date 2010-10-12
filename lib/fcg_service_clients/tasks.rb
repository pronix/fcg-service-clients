Dir[
  File.expand_path("../../../tasks/*.thor", __FILE__),
].each do |file|
  # Thor::Utils.load_thorfile(file)
  require file
end