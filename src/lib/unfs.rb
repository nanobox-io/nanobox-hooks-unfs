module Hooky
  module Unfs

    CONFIG_DEFAULTS = {
      # global settings
      before_deploy: {type: :array, of: :string, default: []},
      after_deploy:  {type: :array, of: :string, default: []},
      hook_ref:      {type: :string, default: "stable"}
    }

  end
end
