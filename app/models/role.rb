class Role < ApplicationRecord
    acts_as_tenant(:organization)

end
