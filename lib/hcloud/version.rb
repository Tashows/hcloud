# frozen_string_literal: true

module HCloud
  module Version
    MAJOR = 1
    MINOR = 4
    PATCH = 0
    PRE   = nil

    VERSION = [MAJOR, MINOR, PATCH].compact.join(".")

    STRING = [VERSION, PRE].compact.join("-")
  end

  NAME = "hcloud"
  VERSION = Version::STRING
end
