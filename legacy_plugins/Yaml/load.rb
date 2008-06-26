def load(config,data)
  require "yaml"
  return YAML.load_file(config["filename"]) || []
end

